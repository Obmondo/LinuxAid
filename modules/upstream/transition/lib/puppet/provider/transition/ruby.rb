require 'puppet/application/resource'

Puppet::Type.type(:transition).provide(:ruby) do
  desc "Ruby provider for transition type. This provider is not platform
    specific."

  def transition
    catalog_resource = @resource[:resource]
    name = catalog_resource.name
    type = catalog_resource.type
    resource_key = [type, name].join('/')

    # Retrive original resource definition attributes from catalog
    catalog_attributes = catalog_resource.to_hash

    # Symbolize keys in attributes parameter
    transition_attributes = @resource[:attributes].each_with_object({}) do |(k, v), new|
      new[k.to_sym] = v
    end

    # Create a transitional, merged set of attributes, sans any attributes
    # with an explicit nil value. Those attributes appear to come from the
    # Type being copied, and we just want to build a new type from a
    # Resource.
    merged = catalog_attributes.merge(transition_attributes).reject do |k, v|
      v.nil? || [:before, :subscribe, :require, :notify].include?(k)
    end

    # Build and apply the resource. There is probably a better way of doing
    # this.
    rsrc = Puppet::Resource.new(type, name, parameters: merged)
    result = Puppet::Resource.indirection.save(rsrc, resource_key)

    # Re-fresh state if the provider supports prefetch.
    unless catalog_resource.provider.nil?
      provider_class = catalog_resource.provider.class
      if provider_class.respond_to?(:prefetch)
        # Clear property hash as prefetch might not update resources that
        # have transitioned to :absent.
        catalog_resource.provider.instance_variable_set(:@property_hash, {})
        provider_class.prefetch(catalog_resource.name => catalog_resource)
      end
    end

    # TODO: Find a better way to log the results ???

    failed = result[1].resource_statuses[rsrc.to_s].events.any? do |event|
      event.status == 'failure'
    end

    if failed
      events = result[1].resource_statuses[rsrc.to_s].events.map do |event|
        "#{event.property}: #{event.message}"
      end
      raise Puppet::Error, events.join('; ')
    end
  end

  def transition?
    priors = @resource[:prior_to]

    # Determine if there are changes pending to any of the prior_to resources.
    pending_change = priors.any? do |resource|
      current_values = resource.retrieve_resource.to_hash

      # if should be absent and is absent, the other properties don't matter
      # (and may trigger false positives).
      current_ensure = current_values[:ensure]
      prop_ensure = resource.property(:ensure)
      if prop_ensure && prop_ensure.should == :absent && prop_ensure.safe_insync?(current_ensure)
        next false
      end

      resource.properties.any? do |property|
        current_value = current_values[property.name]
        if property.should && !property.safe_insync?(current_value)
          true
        else
          false
        end
      end
    end

    # If changes are pending, transition?() will return true.
    pending_change
  end
end
