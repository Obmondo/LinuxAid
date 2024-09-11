# @summary
# A Puppet module, using storeconfigs, to model an haproxy configuration.
# Currently VERY limited - assumes Redhat/CentOS setup. Pull requests accepted!
#
# @note
#
# Currently requires the puppetlabs/concat module on the Puppet Forge and
#  uses storeconfigs on the Puppet Server to export/collect resources
#  from all balancer members.
#
#
# @param package_ensure
#   Ensure the package is present (installed), absent or a specific version.
#   Defaults to 'present'
#
# @param package_name
#   The package name of haproxy. Defaults to 'haproxy'
#   NOTE: haproxy::instance has a different default.
#
# @param service_ensure
#   Chooses whether the haproxy service should be running & enabled at boot, or
#   stopped and disabled at boot. Defaults to 'running'
#
# @param service_manage
#   Chooses whether the haproxy service state should be managed by puppet at
#   all. Defaults to true
#
# @param service_name
#   The service name for haproxy. Defaults to 'haproxy'
#   NOTE: haproxy::instance has a different default.
#
# @param service_options
#   Contents for the `/etc/defaults/haproxy` file on Debian. Defaults to "ENABLED=1\n" on Debian, and is ignored on other systems.
#
# @param chroot_dir_manage
#   Chooses whether the haproxy chroot directory should be managed by puppet
#   at all. Defaults to true
#
# @param sysconfig_options
#   Contents for the `/etc/sysconfig/haproxy` file on RedHat(-based) systems.
#   Defaults to OPTIONS="" on RedHat(-based) systems and is ignored on others
#
# @param global_options
#   A hash of all the haproxy global options. If you want to specify more
#    than one option (i.e. multiple timeout or stats options), pass those
#    options as an array and you will get a line for each of them in the
#    resultant haproxy.cfg file.
#
# @param defaults_options
#   A hash of all the haproxy defaults options. If you want to specify more
#    than one option (i.e. multiple timeout or stats options), pass those
#    options as an array and you will get a line for each of them in the
#    resultant haproxy.cfg file.
#
# @param merge_options
#   Whether to merge the user-supplied `global_options`/`defaults_options`
#   hashes with their default values set in params.pp. Merging allows to change
#   or add options without having to recreate the entire hash. Defaults to
#   false, but will default to true in future releases.
#
# @param restart_command
#   Command to use when restarting the on config changes.
#    Passed directly as the <code>'restart'</code> parameter to the service resource.
#    Defaults to undef i.e. whatever the service default is.
#
# @param custom_fragment
#   Allows arbitrary HAProxy configuration to be passed through to support
#   additional configuration not available via parameters, or to short-circute
#   the defined resources such as haproxy::listen when an operater would rather
#   just write plain configuration. Accepts a string (ie, output from the
#   template() function). Defaults to undef
#
# @param config_dir
#   Path to the directory in which the main configuration file `haproxy.cfg`
#   resides. Will also be used for storing any managed map files (see
#   `haproxy::mapfile`). Default depends on platform.
#
# @param config_file
#   Optional. Path to the haproxy config file.
#   Default depends on platform.
#
# @param config_validate_cmd
#   Optional. Command used by concat validate_cmd to validate new
#   config file concat is a valid haproxy config.
#   Default /usr/sbin/haproxy -f % -c
#
# @param manage_config_dir
#   Optional. 
# @param manage_service
#   Deprecated
# @param enable
#   Deprecated
# @example
#  class { 'haproxy':
#    global_options   => {
#      'log'     => "${::ipaddress} local0",
#      'chroot'  => '/var/lib/haproxy',
#      'pidfile' => '/var/run/haproxy.pid',
#      'maxconn' => '4000',
#      'user'    => 'haproxy',
#      'group'   => 'haproxy',
#      'daemon'  => '',
#      'stats'   => 'socket /var/lib/haproxy/stats'
#    },
#    defaults_options => {
#      'log'     => 'global',
#      'stats'   => 'enable',
#      'option'  => 'redispatch',
#      'retries' => '3',
#      'timeout' => [
#        'http-request 10s',
#        'queue 1m',
#        'connect 10s',
#        'client 1m',
#        'server 1m',
#        'check 10s'
#      ],
#      'maxconn' => '8000'
#    },
#  }
#
class haproxy (
  Variant[Enum['present', 'absent', 'purged', 'disabled', 'installed', 'latest'], String[1]] $package_ensure = 'present',
  String                                        $package_name         = $haproxy::params::package_name,
  Variant[Enum['running', 'stopped'], Boolean]  $service_ensure       = 'running',
  Boolean                                       $service_manage       = true,
  Boolean                                       $chroot_dir_manage    = true,
  String                                        $service_name         = $haproxy::params::service_name,
  String                                        $service_options      = $haproxy::params::service_options,
  String                                        $sysconfig_options    = $haproxy::params::sysconfig_options,
  Hash                                          $global_options       = $haproxy::params::global_options,
  Hash                                          $defaults_options     = $haproxy::params::defaults_options,
  Boolean                                       $merge_options        = $haproxy::params::merge_options,
  Optional[String]                              $restart_command      = undef,
  Optional[String]                              $custom_fragment      = undef,
  Stdlib::Absolutepath                          $config_dir           = $haproxy::params::config_dir,
  Optional[Stdlib::Absolutepath]                $config_file          = $haproxy::params::config_file,
  Boolean                                       $manage_config_dir    = $haproxy::params::manage_config_dir,
  Variant[Stdlib::Absolutepath, String]         $config_validate_cmd  = $haproxy::params::config_validate_cmd,

  # Deprecated
  Optional[Boolean]                             $manage_service       = undef,
  Optional[Boolean]                             $enable               = undef,
) inherits haproxy::params {
  # NOTE: These deprecating parameters are implemented in this class,
  # not in haproxy::instance.  haproxy::instance is new and therefore
  # there should be no legacy code that uses these deprecated
  # parameters.

  # To support deprecating $enable
  if $enable != undef {
    warning('The $enable parameter is deprecated; please use service_ensure and/or package_ensure instead')
    if $enable {
      $_package_ensure = 'present'
      $_service_ensure = 'running'
    } else {
      $_package_ensure = 'absent'
      $_service_ensure = 'stopped'
    }
  } else {
    $_package_ensure = $package_ensure
    $_service_ensure = $service_ensure
  }

  # To support deprecating $manage_service
  if $manage_service != undef {
    warning('The $manage_service parameter is deprecated; please use $service_manage instead')
    $_service_manage = $manage_service
  } else {
    $_service_manage = $service_manage
  }

  haproxy::instance { $title:
    package_ensure      => $_package_ensure,
    package_name        => $package_name,
    service_ensure      => $_service_ensure,
    service_manage      => $_service_manage,
    service_name        => $service_name,
    chroot_dir_manage   => $chroot_dir_manage,
    global_options      => $global_options,
    defaults_options    => $defaults_options,
    restart_command     => $restart_command,
    custom_fragment     => $custom_fragment,
    config_dir          => $config_dir,
    config_file         => $config_file,
    merge_options       => $merge_options,
    service_options     => $service_options,
    sysconfig_options   => $sysconfig_options,
    config_validate_cmd => $config_validate_cmd,
  }
}
