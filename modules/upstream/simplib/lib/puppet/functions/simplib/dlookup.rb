# A function for performing lookups targeted at ease of use with defined types.
#
# Quite often you need to override something in an existing defined type and,
# presently, you have to do this by creating a resource collector and
# potentially ending up with unintended side-effects.
#
# This function introduces the capability to consistently opt-in to a lookup
# syntax for overriding all parameters of a given defined type or parameters on
# a specific instance of a defined type.
#
# This calls `simplib::lookup` under the hood after formatting the parameters
# appropriately but was split out in case the underlying syntax needs to
# change in the future.
#
# There are two ways to call this method as shown in the following examples.
#
# @example Global Options
#
#   In this case, you want to set a parameter on *every* instance of your
#   defined type that is ever called. For example, this may be useful for
#   setting cipher suites to a modified global default to meet company policy.
#
#   This follows the general Puppet nomenclature for class lookups since you
#   cannot have a class and defined type of the same name.
#
#   Function Call:
#
#   ```ruby
#   define mydef::global (
#     $ssl_version = simplib::dlookup('mydef::global', 'ssl_version', { 'default_value' => 'SSLv3' })
#   ) { ... }
#
#   mydef::global { 'test': }
#   ```
#
#   Example Hieradata:
#
#   ```yaml
#   ---
#   mydef::global::ssl_version: 'TLS1.2'
#   ```
#
# @example Specific Instance Options
#
#   In this case, you want to focus on a specific named instance of a defined
#   type resource and change only that parameter. If the specific instance
#   cannot be found, it will fall back to a global lookup for the parameter
#   as in the first example.
#
#   Function Call:
#
#   ```ruby
#   define mydef::specific (
#     $ssl_version = simplib::dlookup('mydef::specific', 'ssl_version', $title, { 'default_value' => 'SSLv3' })
#   ) { ... }
#
#   mydef::specific{ 'test': }
#   ```
#
#   Example Hieradata:
#
#   ```yaml
#   ---
#   "Mydef::Specific[test]::ssl_version": 'TLS1.2'
#   ```
#
#   Note that, in this case, only the `test` instance of the `mydef::specific`
#   resource will have its `ssl_version` set to `TLS1.2`. All others will have
#   their version set to `SSLv3`.
#
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
Puppet::Functions.create_function(:'simplib::dlookup') do
  # @param define_id
  # The literal unique identifier of the defined type resource ('mydef::global'
  # in the examples)
  #
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
  # @return [Any] The discovered data from Hiera
  dispatch :dlookup do
    param          'String[1]', :define_id
    param          'String[1]', :param
    optional_param 'Any',       :options
  end

  # @param define_id
  # The literal unique identifier of the defined type resource ('mydef::specific'
  # in the examples)
  #
  # @param param The parameter that you wish to look up
  #
  # @param resource_title The $title of the resource
  #
  # @param options Hash of options for regular ``lookup()``
  #
  #   * This **must** follow the syntax rules for the
  #   Puppet ``lookup( [<NAME>], <OPTIONS HASH> )`` version of ``lookup()``
  #   * No other formats are supported!
  #
  # @see https://docs.puppet.com/puppet/latest/function.html#lookup - Lookup Function
  #
  # @return [Any] The discovered data from Hiera
  dispatch :dlookup_specific do
    param          'String[1]', :define_id
    param          'String[1]', :param
    param          'String[1]', :resource_title
    optional_param 'Any',       :options
  end

  def dlookup(define_id, param, options)
    target_param = "#{define_id}::#{param}"

    return call_function('simplib::lookup', target_param, options )
  end

  def dlookup_specific(define_id, param, resource_title, options)
    target_param = "#{define_id.split('::').map(&:capitalize).join('::')}[#{resource_title}]::#{param}"

    retval = call_function('simplib::lookup', target_param, options)

    # Fall back to the global lookup for this option
    if retval == options['default_value']
      retval = dlookup(define_id, param, options)
    end

    return retval
  end
end
