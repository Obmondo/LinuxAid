# frozen_string_literal: true

# @summary this function is used to get a list of parameters passed to or resource.
# @example Passing Parameters from a profile straight though to a base class
#
#    class profile::foobar ($param1, $param2) {
#       class { 'foobar':
#         *                => extlib::dump_params,
#         additional_param => 'foobar',
#       }
#     }
#
# @example Passing parameters directly to a config file.
#
#     class foobar ($app_param1, $app_param2, $class_param1) {
#       file { '/etc/foo/config.yaml':
#         ensure => file,
#         # class param and name are not understoof by the foo app
#         content => extlib::dump_params(['name', 'class_param1']).to_yaml
#       }
#     }
#
Puppet::Functions.create_function(:'extlib::dump_params', Puppet::Functions::InternalFunction) do
  # @param filter_keys an optional parameters of keys to filter out.  default value is set to 'name'
  dispatch :dump_params do
    scope_param
    optional_param 'Array[String[1]]', :filter_keys
  end

  def dump_params(scope, filter_keys = ['name'])
    scope.resource.to_hash.transform_keys(&:to_s).reject { |k, _v| filter_keys.include?(k) }
  end
end
