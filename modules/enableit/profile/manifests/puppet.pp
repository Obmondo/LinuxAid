# Manage puppet agent
# We want to stick to PC1 repo
# so we can setup puppet-agent package
class profile::puppet (
  Boolean              $noop_value             = $::common::puppet::noop_value,
  Stdlib::Host         $server                 = $::common::puppet::server,
  Stdlib::Port         $server_port            = $::common::puppet::server_port,
  Eit_types::Version   $version                = $::common::puppet::version,
  Boolean              $setup_agent            = $::common::puppet::setup_agent,
  Boolean              $configure_agent        = $::common::puppet::configure_agent,
  Stdlib::Absolutepath $config_file            = $::common::puppet::config_file,
  Boolean              $run_agent_as_noop      = $::common::puppet::run_agent_as_noop,
  Optional[Hash]       $extra_main_settings    = $::common::puppet::extra_main_settings,
  Optional[String]     $package_version_suffix = undef,
  Optional[String]     $package_version_prefix = undef,
  String               $aio_package_name       = $::common::puppet::package_name,
  String               $environment            = $::common::puppet::environment,
) {

  $puppetversion = $facts['puppetversion']
  $os_major = $facts['os']['release']['major']
  $os_arch = $facts['os']['architecture']

  $_version = if $version == 'latest' {
    $version
  } else {
    "${package_version_prefix}${version}${package_version_suffix}"
  }

  # We need to manage puppet.conf on the puppetmaster, and puppet_agent also
  # tries to do this.
  if $setup_agent {
    # TODO: remove this block, when there is no more puppet-agent 7
    # PuppetLabs
    eit_repos::repo { 'puppetlabs':
      ensure     => false,
      noop_value => $noop_value,
    }

    # Openvox
    eit_repos::repo { 'openvox':
      noop_value => $noop_value,
    }

    # Remove the puppetlabs repo package
    package { [
      'puppet7-release',
      'puppet8-release',
      'puppet-agent'
    ]:
      ensure  => absent,
      noop    => $noop_value,
      notify  => Package[$aio_package_name],
      require => Eit_repos::Repo['openvox'],
    }

    package { $aio_package_name:
      ensure  => $_version,
      noop    => $noop_value,
      require => Eit_repos::Repo['openvox'],
    }

    $_pin_version = !($_version in ['latest', 'held', 'installed', 'absent', 'purged', 'present'])
    if $_pin_version {
      case $facts['package_provider'] {
        'apt': {
          apt::pin { "pin ${aio_package_name}":
            version  => $_version,
            priority => 999,
            packages => $aio_package_name,
          }

          File <| title == "/etc/apt/preferences.d/pin_${aio_package_name}.pref" |> {
            noop => $noop_value,
          }

          # TODO: remove these block when puppetlabs is not anymore.
          File <| title == '/etc/apt/preferences.d/pin_puppet-agent.pref' |> {
            enable => absent,
            noop   => $noop_value,
          }
        }
        'yum': {
          # use yum data types, otherwise assertion fails in yum::versionlock
          $full_package_name = Yum::VersionlockString("0:${aio_package_name}-${version}-*.el${os_major}.${os_arch}")
          yum::versionlock { $full_package_name:
            ensure => present,
          }
          Concat_file <| title == '/etc/yum/plugins/versionlock.list' |> {
            noop => $noop_value,
          }
        }
        'dnf': {
          File {
            noop => $noop_value,
          }

          # use yum data types, otherwise assertion fails in yum::versionlock
          $full_package_name = Yum::RpmName($aio_package_name)

          yum::versionlock { $full_package_name:
            ensure  => present,
            version => $version,
          }
          Concat_file <| title == '/etc/dnf/plugins/versionlock.list' |> {
            noop => $noop_value,
          }
        }
        'zypper': {
          $full_package_name = "${aio_package_name}-${version}-*.sles${os_major}.${os_arch}"
          zypprepo::versionlock { $full_package_name: }

          Concat_file <| title == '/etc/zypp/locks' |> {
            noop => $noop_value,
          }
        }
        default: {
          info("Not pinning the ${aio_package_name} package, maybe you have an older distro")
        }
      }
    }

    ['puppet', 'pxp-agent'].each |$service| {
      service { $service:
        enable  => 'mask',
        noop    => $noop_value,
        require => Package[$aio_package_name],
      }
    }
  }

  $_file_defaults = {
    owner => 'root',
    group => 'obmondo',
    mode  => 'ug+rX,o=',
  }

  if $configure_agent {
    file { $config_file:
      ensure  => present,
      content => epp('profile/puppet.conf.epp', {
        'server'                           => $server,
        'graph'                            => true,
        'noop'                             => $run_agent_as_noop,
        'onetime'                          => false,
        'certname'                         => $::trusted['certname'],
        'manage_internal_file_permissions' => false,
        'environment'                      => $environment,
        'runtimeout'                       => '10m',
        'masterport'                       => $server_port,
        'extra_main_settings'              => $extra_main_settings,
        'splay'                            => true,
        'usecacheonfailure'                => false,
      }),
      noop    => $noop_value,
    }

    file { $facts['puppet_ssldir']:
      ensure => directory,
      *      => $_file_defaults,
      noop   => $noop_value,
    }

    $facts['puppet_sslpaths'].each |$x| {
      [$_name, $_values] = $x

      if $_values['path_exists'] {
        $_path = $_values['path']
        $_is_dir = $_path !~ /\.pem$/

        file { $_path:
          ensure  => if $_is_dir { directory } else { present },
          *       => $_file_defaults,
          noop    => $noop_value,
          recurse => $_is_dir,
        }
      }
    }
  }

  $_puppet_dir = $facts['puppet_confdir'].dirname
  $_facter_dir = "${_puppet_dir}/facter"
  $_facts_d_dir = "${_facter_dir}/facts.d"
  file { functions::dir_to_dirs($_facts_d_dir):
    ensure => 'directory',
    noop   => $noop_value,
  }

  hocon_setting {
    default:
      ensure  => present,
      path    => "${_facter_dir}/facter.conf",
      noop    => $noop_value,
      require => File[$_facts_d_dir],
      ;

    'facter external-dir':
      setting => 'global.external-dir',
      value   => "${_facter_dir}/facts.d",
      ;

    'facter ttls':
      setting => 'facts.ttls',
      type    => 'array_element',
      value   => [
        { 'dmi' => '1 day' },
        { 'packages' => '1 day' },
        { 'partitions' => '1 day' },
        { 'networking' => '1 day' },
        { 'sssd' => '1 day' },
        { 'puppet_sslpaths' => '1 day' }
      ],
      ;

    'facter blocklist':
      setting => 'facts.blocklist',
      type    => 'array_element',
      value   => [
        'network_ports',
        'login_defs',
        'cpuinfo',
        'fips_ciphers',
      ],
      ;

  }

}
