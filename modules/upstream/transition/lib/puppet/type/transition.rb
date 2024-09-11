Puppet::Type.newtype(:transition) do
  @doc = 'Define a transitional state.'

  # The enable property determines whether or not this transition state may be
  # applied. When enable=true, the property will call two methods in the
  # provider. It will call transition?() as its insync method. Therefore
  # transition?() should return true if the transitional state should be
  # implemented, and false if it should not. The transition() method should
  # implement the transitional state.
  newproperty(:enable) do
    desc "Enable or disable this conditional state transition. Valid values
      are true or false."

    newvalues :true, :false
    defaultto :true

    # If the transition should occur and the transition resource is enabled,
    # call the provider's transition() method.
    def sync
      @resource.provider.transition
    end

    # There is no getter method for this property as it is used only as a
    # decision point whether or not to realize the transition behavior if the
    # transition conditions exist. Therefore retrieve should just echo the
    # property value.
    def retrieve
      @resource['enable']
    end

    # When displaying that a change is occuring, use the attributes parameter
    # to print the change.
    def change_to_s(_currentvalue, _newvalue)
      state = @resource[:attributes].inspect
      name  = @resource[:resource].to_s
      "transition state #{state} applied to #{name}"
    end

    def is_to_s(_currentvalue) # rubocop:disable Style/PredicateName
      'enabled'
    end

    def should_to_s(_shouldvalue)
      state = @resource[:attributes].inspect
      name  = @resource[:resource].to_s
      "transition #{name} to state #{state}"
    end

    # Whether or not the resource is insync is determined by the transition?()
    # method of the provider. To transition or not to transition, that is the
    # question.
    def insync?(_is)
      case @resource['enable']
      when :true
        # If a transition should occur, the resource is not insync.
        !@resource.provider.transition?
      else
        # Return true, since a disabled transition is always insync.
        true
      end
    end
  end

  newparam(:resource) do
    desc "The resource for which a transitional state is being defined. This
      should be a resource reference (e.g. Service['apache']). This resource
      will be made to autorequire the transitional state."
  end

  newparam(:attributes) do
    desc "The hash of attributes to set on the resource when applying a
      transitional state. Each hash key must be a valid attribute for the
      resource being transitioned."

    validate do |value|
      raise ArgumentError, "#{value} is not a hash" unless value.is_a? Hash
    end
  end

  newparam(:prior_to, array_matching: :all) do
    desc "An array of resources to check for synchronization. If any of these
      resources are out of sync (change pending), then this transitional state
      will be applied. These resources will each be made to autorequire the
      transitional state."

    munge do |values|
      values = [values] unless values.is_a? Array
      values
    end
  end

  # This resource does not need or use a namevar. However, it is far simpler to
  # define an unused name parameter and make it the namevar than it is to
  # convince Puppet that a namevar isn't needed.
  newparam(:name) do
    isnamevar
    desc "This parameter does not serve any function beyond setting the
      resource's name."
  end

  # All parameters are required (except for name)
  validate do
    [:resource, :attributes, :prior_to].each do |param|
      unless self.parameters[param]
        raise Puppet::Error, "Required parameter missing: #{param}"
      end
    end
  end

  # This type needs to implement an "autobefore" kind of behavior. Currently
  # the Puppet type system only supports autorequire, so we achieve autobefore
  # by hijacking autorequire.
  def autorequire(rel_catalog = nil)
    reqs = super

    [
      @parameters[:prior_to].value,
      @parameters[:resource].value,
    ].flatten.each do |rel|
      reqs << Puppet::Relationship.new(self, catalog.resource(rel.to_s))
    end

    reqs
  end

  def pre_run_check
    # Validate and munge `resource`
    resource = parameter(:resource)
    begin
      resource.value = retrieve_resource_reference(resource.value)
    rescue ArgumentError => err
      raise Puppet::Error, "Parameter resource failed: #{err} at #{@file}:#{@line}"
    end

    # Validate and munge `prior_to`
    prior_to = parameter(:prior_to)
    prior_to.value.map! do |res|
      begin
        retrieve_resource_reference(res)
      rescue ArgumentError => err
        raise Puppet::Error, "Parameter prior_to failed: #{err} at #{@file}:#{@line}"
      end
    end

    # Validate `attributes`
    attributes = parameter(:attributes).value
    res = Puppet::Resource.new(resource.value.to_s)
    attributes.keys.each do |attribute|
      next if res.valid_parameter?(attribute)
      raise Puppet::Error, 'Parameter attributes failed: ' \
        "#{attribute} is not a valid parameter for type #{res.type} " \
        "at #{@file}:#{@line}"
    end
  end

  # Retrieves a resourcereference from the catalog.
  #
  # @raise [ArgumentError] if the object is not a valid resource
  #   reference or does not exist in the catalog.
  # @return [void]
  def retrieve_resource_reference(res)
    case res
    when Puppet::Type      # rubocop:disable Lint/EmptyWhen
    when Puppet::Resource  # rubocop:disable Lint/EmptyWhen
    when String
      begin
        Puppet::Resource.new(res)
      rescue ArgumentError
        raise ArgumentError, "#{res} is not a valid resource reference"
      end
    else
      raise ArgumentError, "#{res} is not a valid resource reference"
    end

    resource = catalog.resource(res.to_s)

    raise ArgumentError, "#{res} is not in the catalog" unless resource

    resource
  end
end
