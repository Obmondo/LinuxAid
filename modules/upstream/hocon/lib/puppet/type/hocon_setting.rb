Puppet::Type.newtype(:hocon_setting) do
  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:setting, namevar: true) do
    desc 'The name of the setting to be defined.'
  end

  newparam(:path, namevar: true) do
    desc 'The file Puppet will ensure contains the specified setting.'
    validate do |value|
      unless (Puppet.features.posix? && value =~ %r{^\/}) || (Puppet.features.microsoft_windows? && (value =~ %r{^.:\/} || value =~ %r{^\/\/[^\/]+\/[^\/]+}))
        raise(Puppet::Error, "File paths must be fully qualified, not '#{value}'")
      end
    end
  end

  newproperty(:type) do
    desc 'The value type'
    # This property has no default. If it is not supplied, the validation of the "value"
    # property will set one automatically.
  end

  newproperty(:value, array_matching: :all) do
    desc 'The value of the setting to be defined.'

    validate do |_val|
      # Grab the value we are going to validate
      value = (@shouldorig.is_a?(Array) && (@shouldorig.size > 1 || @resource[:type] == 'array')) ? @shouldorig : @shouldorig[0]
      case @resource[:type]
      when 'boolean'
        if value != true && value != false
          raise "Type specified as 'boolean' but was #{value.class}"
        end
      when 'string', 'text'
        unless value.is_a?(String)
          raise "Type specified as #{@resource[:type]} but was #{value.class}"
        end
      when 'number'
        # Puppet stringifies numerics in versions of Puppet < 4.0.0
        # Account for this by first attempting to cast to an Integer.
        # Failing that, attempt to cast to a Float or return false
        numeric_as_string = begin
                              Integer(value)
                            rescue
                              false
                            end
        numeric_as_string = begin
                              numeric_as_string ? numeric_as_string : Float(value)
                            rescue
                              false
                            end

        unless value.is_a?(Numeric) || numeric_as_string
          raise "Type specified as 'number' but was #{value.class}"
        end
      when 'array'
        unless value.is_a?(Array)
          raise "Type specified as 'array' but was #{value.class}"
        end
      when 'hash'
        unless value.is_a?(Hash)
          raise "Type specified as 'hash' but was #{value.class}"
        end
      when 'array_element', nil # rubocop:disable Lint/EmptyWhen
      # Do nothing, we'll figure it out on our own
      else
        raise "Type was specified as #{@resource[:type]}, but should have been one of 'boolean', 'string', 'text', 'number', 'array', or 'hash'"
      end
    end

    munge do |value|
      if value.is_a?(String) && @resource[:type] == 'number'
        munged_value = begin
                         Integer(value)
                       rescue
                         false
                       end
        value = munged_value ? munged_value : Float(value)
      end
      value
    end

    def insync?(is)
      # TODO: this doesn't appear to get called, and according to Puppet's source
      # it may be deprecated.
      if @resource[:type] == 'array_element'
        # make sure all passed values are in the file
        Array(@resource[:value]).each do |v|
          unless provider.value.flatten.include?(v)
            return false
          end
        end
        true
      else
        super
      end
    end

    def change_to_s(current, new)
      if @resource[:type] == 'array_element'
        real_new = []
        real_new << current
        real_new << new
        real_new.flatten!
        real_new.uniq!
        "value changed [#{Array(current).flatten.join(', ')}] to [#{real_new.join(', ')}]"
      else
        super
      end
    end
  end

  def self.title_patterns
    # This is the default title pattern for all types, except hard-wired to
    # set the title to :setting instead of :name. This is also hard-wired to
    # ONLY set :setting and nothing else, and this will be overridden if
    # the :setting parameter is set manually.
    [[%r{(.*)}m, [[:setting]]]]
  end

  validate do
    message = ''
    if original_parameters[:path].nil?
      message += 'path is a required parameter. '
    end
    if original_parameters[:setting].nil?
      message += 'setting is a required parameter. '
    end
    if original_parameters[:value].nil? && self[:ensure] != :absent
      message += 'value is a required parameter unless ensuring a setting is absent.'
    end
    if message != ''
      raise(Puppet::Error, message)
    end
  end
end
