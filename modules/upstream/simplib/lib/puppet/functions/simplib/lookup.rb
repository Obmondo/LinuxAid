# A function for falling back to global scope variable lookups when the
# Puppet 4 ``lookup()`` function cannot find a value.
#
# While ``lookup()`` will stop at the back-end data sources,
# ``simplib::lookup()`` will check the global scope first to see if the
# variable has been defined.
#
# This means that you can pre-declare a class and/or use an ENC and look up the
# variable whether it is declared this way or via Hiera or some other back-end.
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
Puppet::Functions.create_function(:'simplib::lookup') do
  # @param param The parameter that you wish to look up
  #
  # @param options Hash of options for regular ``lookup()``
  #
  #   * This **must** follow the syntax rules for the
  #   Puppet ``lookup( [<NAME>], <OPTIONS HASH> )`` version of ``lookup()``
  #   * No other formats are supported!
  #
  # @see https://docs.puppet.com/puppet/latest/function.html#lookup - Lookup Function
  #
  # @return [Any] The value that is found in the system for the passed
  #   parameter.
  #
  # @example No defaults
  #   simplib::lookup('foo::bar::baz')
  #
  # @example With a default
  #   simplib::lookup('foo::bar::baz', { 'default_value' => 'Banana' })
  #
  # @example With a typed default
  #   simplib::lookup('foo::bar::baz', { 'default_value' => 'Banana', 'value_type' => String })
  #
  dispatch :lookup do
    param          'String', :param
    optional_param 'Any',    :options
  end

  def lookup(param, options = nil)
    class_name = param.split('::')

    if class_name.size < 2
      # This is a global variable
      param_name = class_name
      class_name = nil
    else
      param_name = class_name.pop
      class_name = class_name.join('::')
    end

    if param_name
      if class_name
        global_scope = closure_scope.find_global_scope
        catalog = global_scope.catalog

        active_resource = catalog.resource("Class[#{class_name}]")
        if active_resource
          active_resource_param = active_resource.parameters[param_name.to_sym]
          if active_resource_param
            global_param = active_resource_param.value
          end
        end
      else
        # Save the state of the strict vars setting. Ignore it here since we do
        # legitimate global scope lookups but make sure to restore it.
        strict_vars = nil
        begin
          if Puppet[:strict]
            strict_vars = Puppet[:strict]
            Puppet[:strict] = :off
          end

          global_param = closure_scope.find_global_scope.lookupvar(param)
        ensure
          if strict_vars
            Puppet[:strict] = strict_vars
          end
        end
      end
    end

    return global_param if global_param

    return call_function('lookup', param, options) if options

    call_function('lookup', param)
  end
end
