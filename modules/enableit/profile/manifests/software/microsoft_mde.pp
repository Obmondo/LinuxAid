# Microsoft Defender for Endpoint
class profile::software::microsoft_mde (
  Boolean                                $enable              = $common::software::microsoft_mde::enable,
  Eit_types::Noop_Value                  $noop_value          = $common::software::microsoft_mde::noop_value,
  Eit_types::Package::Version::Installed $version             = $common::software::microsoft_mde::version,
  Optional[Eit_Files::Source]            $onboard_config      = $common::software::microsoft_mde::onboard_config,
  Eit_types::Microsoft::Mde::Exclusions  $exclusions          = $common::software::microsoft_mde::exclusions,
) {

  File {
    noop => $noop_value,
  }

  Group {
    noop => $noop_value,
  }

  Package {
    noop => $noop_value,
  }

  Service {
    noop => $noop_value,
  }

  User {
    noop => $noop_value,
  }

  group { 'mdatp':
    ensure => ensure_present($enable),
    system => true,
    noop   => $noop_value,
  }

  $_nologin_path = $facts['os']['distro']['codename'] ? {
    'bionic' => '/usr/sbin/nologin',
    default  => '/sbin/nologin',
  }

  user { 'mdatp':
    ensure             => ensure_present($enable),
    password           => '!!',
    password_max_age   => -1,
    password_min_age   => -1,
    password_warn_days => -1,
    shell              => $_nologin_path,
    require            => if $enable { Group['mdatp'] },
    before             => unless $enable { Group['mdatp'] },
    noop               => $noop_value,
  }

  if $enable {

  # Microsoft doesn't know shit about packaging, so their postinstall script
  # copies the service unit into place instead of simply packaging it. In any
  # case we better ensure the service is running...
    service { 'mdatp':
      ensure    => ensure_service($enable),
      enable    => $enable,
      require   => if $enable { [
        Package['mdatp'],
        User['mdatp'],
      ] },
      before    => unless $enable { Package['mdatp'] },
      # the path in the documentation is wrong...
      subscribe => if $enable {
        File['/etc/opt/microsoft/mdatp/managed/mdatp_onboard.json']
      },
    }

    file { [
      '/etc/opt',
      '/etc/opt/microsoft',
      '/etc/opt/microsoft/mdatp',
      '/etc/opt/microsoft/mdatp/managed',
    ]:
      ensure => 'directory',
      owner  => root,
      group  => root,
      mode   => '0755',
    }

    package { 'mdatp':
      ensure  => $version,
      require => File['/etc/opt/microsoft/mdatp/managed/mdatp_onboard.json'],
    }

    eit_files::file { '/etc/opt/microsoft/mdatp/managed/mdatp_onboard.json':
      ensure     => 'present',
      source     => $onboard_config,
      owner      => root,
      group      => root,
      mode       => '0600',
      noop_value => $noop_value,
      require    => File['/etc/opt/microsoft/mdatp/managed'],
    }


    if $exclusions.size > 0 {
      $_exclusion_lists = $exclusions.map |$items| {
        case $items[0] {
          'excludedFileExtension': {
            $items[1].map |$x| {
              {
                '$type'     => $items[0],
                'extension' => $x
              }
            }
          }
          'excludedPath': {
            $items[1].map |$x| {
              {
                '$type'       => $items[0],
                'isDirectory' => false,
                'path'        => $x
              }
            }
          }
          'excludedDirectory': {
            $items[1].map |$x| {
              {
                '$type'       => 'excludedPath',
                'isDirectory' => true,
                'path'        => $x
              }
            }
          }
          'excludedFileName': {
            $items[1].map |$x| {
              {
                '$type' => $items[0],
                'name'  => $x
              }
            }
          }
          default: {
            fail("${items[0]} is not supported as of now")
          }
        }
      }.flatten

      file { '/etc/opt/microsoft/mdatp/managed/mdatp_managed.json':
        ensure  => 'present',
        noop    => $noop_value,
        content => stdlib::to_json({
          'antivirusEngine' => {
            'exclusions' => $_exclusion_lists,
          }
        }),
        owner   => root,
        group   => root,
        mode    => '0600',
        require => File['/etc/opt/microsoft/mdatp/managed'],
      }
    }

  } else {
    if $facts['init_system'] == 'systemd' {
      service { ['mdatp']:
        ensure => 'stopped',
        enable => mask,
      }
    }

    package { 'mdatp':
      ensure => 'absent',
    }

    file { '/etc/opt/microsoft/mdatp':
      ensure  => 'absent',
      recurse => true,
      force   => true,
    }
  }
}
