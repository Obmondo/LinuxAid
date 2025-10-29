# Repos Management
class eit_repos (
  Boolean               $purge           = false,
  Boolean               $upstream        = false,
  Boolean               $purge_pins      = true,
  Optional[Boolean]     $noop_value      = undef,
  Enum['http', 'https'] $source_protocol = 'https',
) {

  $distro_id = $facts['os']['name']

  File {
    noop => false,
  }

  Exec {
    noop => false,
  }

  confine(!($facts['package_provider'] in ['apt', 'yum', 'dnf', 'zypper']),
          "provider ${facts['package_provider']} (${facts['os']['family']}) is not supported")

  # We most likely don't want $noop_value to be `true` (because that causes noop
  # to be forced); we most likely intend to use `undef` instead.
  if $noop_value {
    notify { '$noop_value is true!': }
  }

  case $facts['os']['family'] {
    'Debian': {
      class { 'apt':
        # https://forge.puppet.com/puppetlabs/apt#update-the-list-of-packages
        update => {
          'frequency' => 'always',
          'loglevel'  => 'debug',
        },
        purge  => {
          'sources.list'   => $purge,
          'sources.list.d' => $purge,
          # NOTE: This might purge too much, but since it can't remove just pins
          # with the apt package this is the only way we're able to do it...
          'preferences'    => $purge_pins,
          'preferences.d'  => $purge_pins,
        },
      }
      # Ensure that all Apt resources are handled before Package resources
      $_defined_apt_classes = [
        'apt::conf',
        'apt::key',
        'apt::pin',
        'apt::ppa',
        'apt::setting',
        'apt::source',
        'apt::update',
      ].filter |$_class| {
        defined(Class[$_class])
      }

      if $upstream {
        eit_repos::apt::upstream.include
      }

      Class[$_defined_apt_classes] -> Package<| provider == 'apt' |>
    }
    'RedHat': {
      # Necessary to be able to purge versionlocks
      include 'yum::plugin::versionlock'

      yum::config { 'deltarpm' :
        ensure => 0,
      }

      yum::config { 'metadata_expire':
        ensure => 3600,
      }

      if $purge {
        # Skip the Redhat repos, it's managed via rh_repo in common::repo::rhrepos
        purge { 'yumrepo':
          unless => ['baseurl', '=~', '^https://cdn.redhat.com' ],
          noop   => $noop_value,
          notify => Exec['remove empty yum repo files'],
        }
      }

      exec { 'remove empty yum repo files':
        command     => 'find /etc/yum.repos.d -empty -delete',
        refreshonly => true,
        path        => [
          '/bin',
          '/usr/bin',
          '/usr/sbin',
          '/usr/local/bin',
        ],
      }

      # Add Upstream repo
      case $distro_id {
        'RedHat': {
          include yum

          lookup('eit_repos::upstream::repos').each |$repo| {
            rh_repo { $repo:
              ensure => present,
              noop   => $noop_value,
            }
          }
        }
        'CentOS': {
          class { 'yum':
            manage_os_default_repos => $upstream,
          }
        }
        default: {
          fail("This ${distro_id} is not supported for upstream repos")
        }
      }

      # Ensure that all Yumrepo resources are handled before Package resources.
      # Special exception for the redhat-release and centos-release packages, as
      # these contains RPM GPG keys, amongst other things.
      Yumrepo<||> -> Package<| name != 'centos-release' and name != 'redhat-release' |>
    }
    'Suse': {
      # TODO: add support for deltarpm and metadata_expire, just like we do for EL

      if $upstream {
        eit_repos::zypper::upstream.include
      }

      include 'zypprepo::plugin::versionlock'

      file { '/etc/pki/rpm-gpg':
        ensure => directory,
        noop   => $noop_value,
      }

      # Skip the Redhat repos, it's managed via rh_repo in common::repo::rhrepos
      if $purge {
        purge { 'zypprepo':
          unless => [
            ['baseurl', '=~', '^https://download.opensuse.org' ],
            ['baseurl', '=~', '^https://updates.suse.com' ],
          ],
          noop   => $noop_value,
          notify => Exec['remove empty Suse repo files'],
        }
      }

      exec { 'remove empty Suse repo files':
        command     => 'find /etc/zypp/repos.d -empty -delete',
        refreshonly => true,
        path        => [
          '/bin',
          '/usr/bin',
          '/usr/sbin',
          '/usr/local/bin',
        ],
      }
    }
    default: {
      fail('Unsuported OS/distribution')
    }
  }
}
