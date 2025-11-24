# @summary Class for managing software repositories
#
# @param manage Boolean - If true, will manage the apt.conf/yum.conf file and set up default configs. Defaults to true.
#
# @param noop_value Optional[Boolean] - Specify whether to perform actions in noop mode. Defaults to undef.
#
# @param repos Array[Variant[String, Hash]] - List of repositories to manage. Defaults to empty array.
#
# @param rhrepos Array[String] - List of RedHat repositories to manage. Defaults to empty array.
#
# @param yumrepos Hash[String, Hash] - Specific yum repository configurations. Defaults to empty hash.
#
# @param zypprepos Hash[String, Struct[
#   {
#     url           => String,
#     repos         => Optional[String],
#     gpgkey        => Optional[String],
#     gpgcontent    => Optional[String],
#     autorefresh  => Boolean,
#     type          => String,
#     path          => String,
#     keeppackages => Boolean,
#   }
# ]] - Specific zypper repository configurations. Defaults to empty hash.
#
# @param aptrepos Hash[String, Hash] - Specific apt repository configurations. Defaults to empty hash.
#
# @param purge Boolean - If true, will purge existing repositories. Defaults to false.
#
# @param upstream Boolean - If true, will set up upstream repositories. Defaults to false.
#
# @param source_protocol Enum['http', 'https']
# The protocol to use for sources. Defaults to 'https'.
#
# @param local Boolean - If true, sets up local repositories. Defaults to false.
#
# @param domain Optional[Stdlib::Fqdn] - The domain for local or remote repositories. Defaults to undef.
#
# @param snapshot Optional[Eit_types::Date] - Date for snapshot repositories. Defaults to undef.
#
class common::repo (
  Boolean                   $manage          = true,
  Eit_types::Noop_Value     $noop_value      = undef,
  Array[
    Variant[
      String,
      Hash
    ]
  ]                         $repos           = [],
  Array                     $rhrepos         = [],
  Hash[String, Hash]        $yumrepos        = {},
  Hash[String, Hash]        $zypprepos       = {},
  Hash[String, Struct[
    {
    url         => String,
    repos       => Optional[String],
    key_content => Optional[String[1]],
    key_source  => Optional[Stdlib::Filesource],
    }]]                     $aptrepos        = {},
  Boolean                   $purge           = false,
  Boolean                   $upstream        = false,
  Enum['http', 'https']     $source_protocol = 'https',
  Boolean                   $local           = false,
  Optional[Stdlib::Fqdn]    $domain          = undef,
  Optional[Eit_types::Date] $snapshot        = undef,
) {
  File {
    noop => $noop_value,
  }
  Apt_Key {
    noop => $noop_value,
  }

  # Get the architecture
  $architecture = $facts['os']['architecture'] ? {
    'aarch64' => 'arm64',
    default   => 'amd64',
  }

  if $manage {
    class { 'eit_repos':
      purge           => $purge,
      upstream        => $upstream,
      source_protocol => $source_protocol,
      noop_value      => $noop_value,
    }
    $repos.each |$repo| {
      if type($repo) =~ Type[Hash] {
        $repo.each |$k, $v| {
          eit_repos::repo { $k:
            noop_value => $noop_value,
            *          => $v,
          }
        }
      } else {
        eit_repos::repo { $repo:
          noop_value => $noop_value,
        }
      }
    }
    $_snapshot_uri_fragment = if $snapshot {
      # Compare two dates, if the install date is newer then the group specific snapshot date and
      # only change the apt/yum repos location, if the install date is lower then the snapshote date
      case $facts['install_date'] {
        Undef: { "snapshots/${snapshot}/" }
        default: {
          if Integer($snapshot.split('-').join) > $facts['install_date'] {
            "snapshots/${snapshot}/"
          }
        }
      }
    }
    $_os = $facts['os']
    $_os_major = $_os['release']['major']
    $_osfamily = $_os['family']
    $_os_codename = $_os.dig('distro', 'codename')

    # Some custom repos for customer, which they can setup
    case $_osfamily {
      'RedHat': {
        $manage_update = lookup('common::system::updates::enable', Boolean, undef, false)
        $snapshot_repo = lookup('common::system::updates::snapshot', Boolean, undef, true)

        # fail only when snapshot repos are enabled
        if $manage_update and $snapshot_repo {
          $yumrepos.each |$_name, $_parameters| {
            if $_parameters['baseurl'] !~ /\$\{snapshot\}/ and $_parameters['baseurl'] !~ /freight/ {
              fail("Repository '${_name}' is missing snapshot placeholder, which is required if automatic system updates are enabled. Please change the URL to contain an EPP style template.") #lint:ignore:140chars
            }
          }
        }
        $yumrepos.each |$key, $value| {
          yumrepo { $key:
            descr    => pick($value['name'], $key),
            baseurl  => $value['baseurl'].inline_epp({ snapshot => $snapshot, }),
            target   => $value['target'],
            gpgkey   => if $value['gpgkey'] { "file://${value['gpgkey']}" },
            gpgcheck => pick($value['gpgcheck'], 1),
            enabled  => 1,
            noop     => $noop_value,
          }
          if $value[gpgkey] {
            eit_repos::yum::gpgkey { $key:
              ensure     => present,
              path       => $value['gpgkey'],
              source     => $value['gpgcontent'],
              noop_value => $noop_value,
            }
          }
        }
        $rhrepos.each |$repo| {
          rh_repo { $repo:
            ensure => present,
            noop   => $noop_value,
          }
        }
      }
      'Debian': {
        $aptrepos.each |$key, $value| {
          apt::source { $key:
            ensure       => present,
            noop         => $noop_value,
            architecture => $architecture,
            release      => $_os_codename,
            comment      => "${key} repo server",
            location     => $value['url'].inline_epp({ snapshot => $snapshot, }),
            repos        => pick($value['repos'], main),
            keyring      => "/etc/apt/keyrings/${key}.asc",
            include      => {
              'src' => false,
              'deb' => true,
            },
          }
          apt::keyring { "${key}.asc":
            ensure  => present,
            source  => $value['key_source'],
            content => $value['key_content'],
            noop    => $noop_value,
          }
        }
      }
      'Suse': {
        $zypprepos.each |$key, $value| {
          zypprepo { $key:
            descr        => pick($value['name'], $key),
            baseurl      => $value['baseurl'].inline_epp({ snapshot => $snapshot, }),
            gpgkey       => if $value['gpgkey'] { "file://${value['gpgkey']}" },
            gpgcheck     => pick($value['gpgcheck'], 1),
            enabled      => 1,
            autorefresh  => $value['autorefresh'],
            type         => $value['type'],
            path         => $value['path'],
            keeppackages => $value['keeppackages'],
            noop         => $noop_value,
          }
          if $value['gpgkey'] {
            eit_repos::yum::gpgkey { $key:
              ensure     => present,
              path       => $value['gpgkey'],
              source     => $value['gpgcontent'],
              noop_value => $noop_value,
            }
          }
        }
      }
      'Lede openwrt': {
        info("Nothing to do for ${_osfamily}")
      }
      default: {
        fail("${_osfamily} is not supported")
      }
    }
    if $local {
      case $_osfamily {
        'RedHat': {
          if $_os['name'] == 'RedHat' {
            file { [
              '/etc/yum.repos.d/centos.repo',
              '/etc/yum.repos.d/base.repo',
              '/etc/yum.repos.d/extras.repo',
              '/etc/yum.repos.d/updates.repo',
              ]:
                ensure => absent,
                noop   => $noop_value,
            }
          }
          if $_os['name'] == 'CentOS' {
            ['base', 'extras', 'updates'].each |$repo| {
              $_repo = if $repo == 'base' { 'os' } else { $repo }
              yumrepo { $_repo:
                ensure   => present,
                noop     => $noop_value,
                enabled  => 1,
                gpgcheck => 1,
                gpgkey   => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-${_os_major}",
                descr    => "CentOS-\$releasever - ${repo.capitalize}",
                baseurl  => "https://${domain}/${_snapshot_uri_fragment}yum/centos${_os_major}/${_repo}/\$basearch/",
                target   => '/etc/yum.repos.d/centos.repo',
              }
              eit_repos::yum::gpgkey { $repo:
                ensure     => present,
                path       => "/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-${_os_major}",
                source     => "puppet:///modules/eit_repos/yum/RPM-GPG-KEY-CentOS-${_os_major}",
                noop_value => $noop_value,
              }
            }
          }
          yumrepo { 'epel_local':
            ensure   => present,
            noop     => $noop_value,
            enabled  => 1,
            gpgcheck => 1,
            gpgkey   => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-${_os_major}",
            descr    => "Extra Packages for Enterprise Linux ${_os_major} \$basearch",
            baseurl  => "https://${domain}/${_snapshot_uri_fragment}yum/epel/${_os_major}/\$basearch/",
            target   => '/etc/yum.repos.d/epel.repo',
          }
          eit_repos::yum::gpgkey { 'epel_local':
            ensure     => present,
            path       => "/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-${_os_major}",
            source     => "puppet:///modules/eit_repos/yum/RPM-GPG-KEY-EPEL-${_os_major}",
            noop_value => $noop_value,
          }
        }
        'Debian': {
          $_os_type = downcase($_os['distro']['id'])

          if $facts['os']['architecture'] == 'aarch64' {
            $apt_repo = "${_os_type}_arm64"
          } else {
            $apt_repo = $_os_type
          }

          $feature_repo = $_os_type ? {
            'ubuntu' => ['backports', 'security', 'updates'],
            'debian' => ['backports', 'updates'],
            default  => fail("${_os_type} not supported")
          }
          $feature_repo.each |$repo| {
            apt::source { "local_apt_repo_${_os_codename}-${repo}":
              ensure       => present,
              noop         => $noop_value,
              architecture => $architecture,
              release      => "${_os_codename}-${repo}",
              comment      => "local apt ${_os_codename}-${repo} server",
              location     => "https://${domain}/${_snapshot_uri_fragment}apt/${apt_repo}",
              repos        => 'main universe multiverse restricted',
              keyring      => "/usr/share/keyrings/${_os_type}-archive-keyring.gpg",
              include      => {
                'src' => false,
                'deb' => true,
              },
            }
          }
          apt::source { "local_apt_repo_${_os_codename}":
            ensure       => present,
            noop         => $noop_value,
            architecture => $architecture,
            release      => $_os_codename,
            comment      => 'local apt repo server',
            location     => "https://${domain}/${_snapshot_uri_fragment}apt/${apt_repo}",
            repos        => 'main universe multiverse restricted',
            keyring      => "/usr/share/keyrings/${_os_type}-archive-keyring.gpg",
            include      => {
              'src' => false,
              'deb' => true,
            },
          }
        }
        'Suse': {
          info("Nothing to do for ${_osfamily}")
        }
        'Lede openwrt': {
          info("Nothing to do for ${_osfamily}")
        }
        default: {
          fail("${_osfamily} is not supported")
        }
      }
    }
  }
}
