# Hiera v5 backend that takes a list of allowed hiera key names, and only
# returns results from the underlying backend function that match those keys.
#
# This allows hiera data to be delegated to end users in a multi-tenant
# environment without allowing them the ability to override every hiera data
# point (and potentially break systems)
#
# @example Enabling the Backend
#   ---
#   version: 5 # Specific version of hiera we are using, required for v4 and v5
#   defaults:  # Used for any hierarchy level that omits these keys.
#     datadir: "data"         # This path is relative to hiera.yaml's directory.
#     data_hash: "yaml_data"  # Use the built-in YAML backend.
#   hierarchy: # Each hierarchy consists of multiple levels
#     - name: "OSFamily"
#       path: "osfamily/%{facts.os.family}.yaml"
#     - name: "datamodules"
#       data_hash: simplib::filtered
#       datadir: "delegated-data"
#       paths:
#         - "%{facts.sitename}/osfamily/%{facts.os.family}.yaml"
#         - "%{facts.sitename}/os/%{facts.os.name}.yaml"
#         - "%{facts.sitename}/host/%{facts.networking.fqdn}.yaml"
#         - "%{facts.sitename}/common.yaml"
#       options:
#         function: yaml_data
#       filter:
#         - profiles::ntp::servers
#         - profiles::.*
#     - name: "Common"
#       path: "common.yaml"
Puppet::Functions.create_function(:'simplib::filtered') do
  # @param options
  # @param context
  #
  # @return [Hash]
  dispatch :filtered do
    param 'Hash', :options
    param 'Puppet::LookupContext', :context
  end

  # @param key
  # @param options
  # @param context
  #
  # @return [Hash]
  dispatch :filtered_lookup_key do
    param 'String', :key
    param 'Hash', :options
    param 'Puppet::LookupContext', :context
  end

  def filtered(options, context)
    backend = call_function(options['function'], options, context)
    data = {}
    backend.each do |key, value|
      check_filter(key, options['filter']) do |nkey|
        data[nkey] = value
      end
    end
    data
  end

  def filtered_lookup_key(key, options, context)
    retval = nil
    check_filter(key, options['filter']) do |k|
      retval = call_function(options['function'], k, options, context)
      if retval.nil?
        context.not_found
      end
    end
    if retval.nil?
      context.not_found
    else
      retval
    end
  end

  def check_filter(key, filter)
    filtered = false
    filter.each do |keyname|
      if key&.match?(Regexp.new(keyname))
        filtered = true
      end
    end
    return unless filtered == false
    yield key
  end
end
# vim: set expandtab ts=2 sw=2:
