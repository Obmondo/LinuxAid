# A class for configuring DataStax Enterprise (DSE) specific settings.
#
# @param config_file [string] The full path to the DSE configuration file.
# @param config_file_mode [string] The mode for the DSE configuration file.
# @param dse_yaml_tmpl [string] A path to a template for the `dse.yaml` file.
# @param file_lines [hash] A hash of values that are passed to
#   `create_resources` as a `file_line` resource.
# @param service_refresh [boolean] Whether or not the Cassandra service
#   should be refreshed if the DSE configuration files are changed.
# @param settings [hash] Unless this attribute is set to a hash (which is
#   then placed as YAML inside `dse.yaml`) then the `dse.yaml` is left
#   unchanged.
# @example Configure a cluster with LDAP authentication
#   class { 'cassandra::dse':
#     file_lines => {
#       'Set HADOOP_LOG_DIR directory' => {
#         ensure => present,
#         path   => '/etc/dse/dse-env.sh',
#         line   => 'export HADOOP_LOG_DIR=/var/log/hadoop',
#         match  => '^# export HADOOP_LOG_DIR=<log_dir>',
#       },
#       'Set DSE_HOME'                 => {
#         ensure => present,
#         path   => '/etc/dse/dse-env.sh',
#         line   => 'export DSE_HOME=/usr/share/dse',
#         match  => '^#export DSE_HOME',
#       },
#     },
#     settings   => {
#       ldap_options => {
#         server_host                => localhost,
#         server_port                => 389,
#         search_dn                  => 'cn=Admin',
#         search_password            => secret,
#         use_ssl                    => false,
#         use_tls                    => false,
#         truststore_type            => jks,
#         user_search_base           => 'ou=users,dc=example,dc=com',
#         user_search_filter         => '(uid={0})',
#         credentials_validity_in_ms => 0,
#         connection_pool            => {
#           max_active => 8,
#           max_idle   => 8,
#         }
#       }
#     }
#   }
class cassandra::dse (
  $config_file      = '/etc/dse/dse.yaml',
  $config_file_mode = '0644',
  $dse_yaml_tmpl    = 'cassandra/dse.yaml.erb',
  $file_lines       = undef,
  $service_refresh  = true,
  $settings         = undef,
) {
  include cassandra
  include stdlib

  if $service_refresh {
    $notifications = Service['cassandra']
  } else {
    $notifications = []
  }

  if is_hash($file_lines) {
    $default_file_line = {
      require => Package['cassandra'],
      notify  => $notifications,
    }

    create_resources(file_line, $file_lines, $default_file_line)
  }

  if is_hash($settings) {
    file { $config_file:
      ensure  => file,
      owner   => 'cassandra',
      group   => 'cassandra',
      content => template($dse_yaml_tmpl),
      mode    => $config_file_mode,
      require => Package['cassandra'],
      notify  => $notifications,
    }
  }
}
