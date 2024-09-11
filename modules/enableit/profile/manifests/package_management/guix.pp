# Guix server
class profile::package_management::guix (
  Optional[Eit_types::SimpleString] $listen_interface,
  Optional[Array[Stdlib::Host]] $clients,
  Integer[1,99] $guix_builders = 10,
  Enum['x86_64-linux'] $system = 'x86_64-linux',
  Eit_types::URL $install_source = "ftp://alpha.gnu.org/gnu/guix/guix-binary-0.15.0.${system}.tar.xz",
) inherits ::profile {

  include ::profile::storage::nfs::server

  # FIXME: Why doesn't this work?
  # confine(lookup('common::storage::nfs::enable', Boolean, undef, false),
  #         'NFS must be enabled')

  $_install_source_file_name = basename($install_source)

  archive { $_install_source_file_name:
    path          => "/tmp/${_install_source_file_name}",
    source        => $install_source,
    checksum      => '4f55c8e70bb56bc5bbdd891908dbdabbc3bc7501b2ef72f9c9cd3a8fa123c514',
    checksum_type => 'sha256',
    extract       => true,
    extract_path  => '/tmp',
    creates       => '/var/guix',
    cleanup       => true,
    before        => Service['guix-daemon.service'],
  }

  exec { 'install guix':
    command     => 'mv /tmp/var/guix /var/guix && mv /tmp/gnu /gnu',
    path        => $::path,
    refreshonly => true,
    subscribe   => Archive[$_install_source_file_name],
    before      => Service['guix-daemon.service'],
  }

  exec { 'authorize hydra substitutes':
    command     => 'guix archive --authorize < ~root/.guix-profile/share/guix/hydra.gnu.org.pub ',
    path        => '/usr/local/bin',
    refreshonly => true,
    subscribe   => Exec['install guix'],
    before      => Service['guix-daemon.service'],
  }

  exec { 'install guix hello':
    command     => 'guix package -i hello',
    path        => '/usr/local/bin',
    refreshonly => true,
    require     => Service['guix-daemon.service'],

  }

  exec { 'install glibc-utf8-locales':
    command     => 'guix package -i glibc-utf8-locales',
    path        => '/usr/local/bin',
    refreshonly => true,
    require     => Service['guix-daemon.service'],
  }

  group { 'guixbuild':
    ensure => 'present',
    system => true,
    before => Service['guix-daemon.service'],
  }

  $_guix_builder_users = Integer[1,$guix_builders].map |$i| {
    $_name = sprintf('guixbuilder%02d', $i)

    user { $_name:
      ensure  => 'present',
      gid     => 'guixbuild',
      groups  => 'guixbuild',
      comment => 'Guix build user %02d'.sprintf($i),
      require => Group['guixbuild'],
      before  => Service['guix-daemon.service'],
    }

    $_name
  }

  firewall_multi {'000 allow guix':
    jump    => 'accept',
    iniface => $listen_interface,
    source  => $clients,
    dport   => 44146,
    proto   => 'tcp',
  }

  profile::storage::nfs::server::export {'/gnu/store':
    options => [
      'rw',
      'async',
    ],
    clients => $clients,
    require => File['/gnu/store'],
  }

  profile::storage::nfs::server::export { '/var/guix':
    options => [
      'rw',
      'async',
    ],
    clients => $clients,
    require => File['/var/guix'],
  }

  common::services::systemd { 'guix-daemon.service':
    unit    => {
      'Description' => 'Build daemon for GNU Guix',
    },
    service => {
      'EnvironmentFile' => '-/etc/default/guix-daemon',
      'Environment'     => 'GUIX_LOCPATH=/root/.guix-profile/lib/locale',
      'ExecStart'       => '/var/guix/profiles/per-user/root/guix-profile/bin/guix-daemon --build-users-group=guixbuild --listen=0.0.0.0 --listen=/var/guix/daemon-socket/socket', #lint:ignore:140chars
      'RemainAfterExit' => 'yes',
      'StandardOutput'  => 'syslog',
      'StandardError'   => 'syslog',
      'Restart'         => 'always',
      'RestartSec'      => '2m',
      # See
      # <https://lists.gnu.org/archive/html/guix-devel/2016-04/msg00608.html>.
      # Some package builds (for example, go@1.8.1) may require even more than
      # 1024 tasks.
      'TasksMax'        => '8192',
    },
    install => {
      'WantedBy' => 'multi-user.target',
    },
    require => User[$_guix_builder_users],
  }

}
