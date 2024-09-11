# @!visibility private
class zfs::install {

  if $zfs::manage_repo {
    case $facts['os']['family'] {
      'RedHat': {
        file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux':
          ensure  => file,
          owner   => 0,
          group   => 0,
          mode    => '0644',
          content => file("${module_name}/RPM-GPG-KEY-zfsonlinux"),
        }

        $baseurl = 'http://download.zfsonlinux.org'
        $release = $facts['os']['release']['major'] ? {
          '6'     => '6',
          '7'     => $facts['os']['release']['full'] ? {
            /^7\.[012]/ => '7',
            default     => regsubst($facts['os']['release']['full'], '^7\.(\d+).*$', '7.\1'),
          },
          '8'     => $facts['os']['release']['full'] ? {
            /^8\.4/ => '8.3',
            default => regsubst($facts['os']['release']['full'], '^8\.(\d+).*$', '8.\1'),
          },
          default => regsubst($facts['os']['release']['full'], '^(\d\.\d+).*$', '\1'),
        }

        Yumrepo {
          ensure          => present,
          metadata_expire => '7d',
          gpgcheck        => 1,
          gpgkey          => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux',
          require         => File['/etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux'],
          before          => Package[$zfs::package_name],
        }

        yumrepo { 'zfs':
          baseurl => "${baseurl}/epel/${release}/\$basearch/",
          descr   => "ZFS on Linux for EL${facts['os']['release']['major']} - dkms",
          enabled => Integer($zfs::kmod_type == 'dkms'),
        }

        yumrepo { 'zfs-kmod':
          baseurl => "${baseurl}/epel/${release}/kmod/\$basearch/",
          descr   => "ZFS on Linux for EL${facts['os']['release']['major']} - kmod",
          enabled => Integer($zfs::kmod_type == 'kabi'),
        }

        yumrepo { 'zfs-source':
          baseurl => "${baseurl}/epel/${release}/SRPMS/",
          descr   => "ZFS on Linux for EL${facts['os']['release']['major']} - Source",
          enabled => 0,
        }

        yumrepo { 'zfs-testing':
          baseurl => "${baseurl}/epel-testing/${release}/\$basearch/",
          descr   => "ZFS on Linux for EL${facts['os']['release']['major']} - dkms - Testing",
          enabled => 0,
        }

        yumrepo { 'zfs-testing-kmod':
          baseurl => "${baseurl}/epel-testing/${release}/kmod/\$basearch/",
          descr   => "ZFS on Linux for EL${facts['os']['release']['major']} - kmod - Testing",
          enabled => 0,
        }

        yumrepo { 'zfs-testing-source':
          baseurl => "${baseurl}/epel-testing/${release}/SRPMS/",
          descr   => "ZFS on Linux for EL${facts['os']['release']['major']} - Testing Source",
          enabled => 0,
        }
      }
      default: {
        # noop
      }
    }
  }

  # Handle these dependencies separately as they shouldn't be guarded by
  # `$zfs::manage_repo`
  case $facts['os']['family'] {
    'RedHat': {
      case $zfs::kmod_type {
        'dkms': {
          # Puppet doesn't like managing multiple versions of the same package.
          # By using the version in the name Yum will do the right thing
          ensure_packages(["kernel-devel-${facts['kernelrelease']}"], {
            ensure => present,
            before => Package[$zfs::package_name],
          })
        }
        default: {
          # noop
        }
      }
    }
    'Debian': {
      case $facts['os']['name'] {
        'Ubuntu': {
          # noop
        }
        default: {
          ensure_packages(["linux-headers-${facts['kernelrelease']}", "linux-headers-${facts['os']['architecture']}"], {
            before => Package[$zfs::package_name],
          })
        }
      }
    }
    default: {
      # noop
    }
  }

  # This is to work around the broken Debian 9 packages. Upon install the
  # zfs-mount.service is started first which is the only unit that doesn't
  # have an "ExecStartPre=-/sbin/modprobe zfs" line so the package can never
  # be installed!
  if $facts['os']['name'] == 'Debian' and $facts['os']['release']['major'] == '9' {
    exec { 'zfs systemctl daemon-reload':
      command     => 'systemctl daemon-reload',
      refreshonly => true,
      path        => $facts['path'],
    }

    Exec['zfs systemctl daemon-reload'] -> Package[$zfs::package_name]

    file { '/etc/systemd/system/zfs-mount.service.d':
      ensure => directory,
      owner  => 0,
      group  => 0,
      mode   => '0644',
    }

    file { '/etc/systemd/system/zfs-mount.service.d/override.conf':
      ensure  => file,
      owner   => 0,
      group   => 0,
      mode    => '0644',
      content => @(EOS/L),
        [Service]
        ExecStartPre=-/sbin/modprobe zfs
        | EOS
      notify  => Exec['zfs systemctl daemon-reload'],
    }
  }

  # These need to be done here so the kernel settings are present before the
  # package is installed and potentially loading the kernel module
  $config = delete_undef_values({
    'zfs_arc_max' => $zfs::zfs_arc_max,
    'zfs_arc_min' => $zfs::zfs_arc_min,
  })

  $config.each |$option,$value| {
    kmod::option { "zfs ${option}":
      module => 'zfs',
      option => $option,
      value  => $value,
      before => Package[$zfs::package_name],
    }
  }

  package { $zfs::package_name:
    ensure => present,
  }
}
