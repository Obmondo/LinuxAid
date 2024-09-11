# Guix client
class profile::package_management::guix::client (
  Boolean      $enable        = $::common::system::package_management::guix::client::enable,
  Boolean      $manage_mounts = $::common::system::package_management::guix::client::manage_mounts,
  Stdlib::Host $server        = $::common::system::package_management::guix::client::server,
  Optional[String] $nfs_base = undef,
) {

  ::common::system::nscd.contain

  $_do_mount = $enable and !($server in ['localhost', $facts['fqdn']])
  $_ensure_link = ensure_present($enable, 'link')

  if $enable and $manage_mounts {
    file {
      default:
        ensure => 'directory',
        owner  => undef,
        group  => undef,
        mode   => undef,
        ;

      '/gnu':
        before => File['/gnu/store'],
        ;

      ['/gnu/store', '/var/guix']:
        ;

    }

    if $_do_mount {
      $_nfs_base = if $nfs_base {
        $nfs_base
      } else {
        "${server}:"
      }

      profile::storage::mount {
        default:
          ensure => 'mounted',
          fstype => 'nfs',
          before => File['/usr/local/bin/guix'],
          ;

        '/gnu/store':
          device  => "${_nfs_base}/gnu/store",
          require => File['/gnu/store'],
          ;

        '/var/guix':
          device  => "${_nfs_base}/var/guix",
          require => File['/var/guix'],
          ;
      }
    }
  }

  file { '/usr/local/bin/guix':
    ensure => $_ensure_link,
    target => '/var/guix/profiles/per-user/root/guix-profile/bin/guix',
  }

  file { '/etc/profile.d/guix.sh':
    ensure  => ensure_file($enable),
    content => epp('profile/package_management/guix/profile.sh.epp', {
      daemon_socket => "guix://${server}"
    }),
  }

  file { '/etc/profile.d/guix.csh':
    ensure  => ensure_file($enable),
    content => epp('profile/package_management/guix/profile.csh.epp', {
      daemon_socket => "guix://${server}"
    }),
  }

  file { '/root/.guix-profile':
    ensure => $_ensure_link,
    target => '/var/guix/profiles/per-user/root/guix-profile',
  }


}
