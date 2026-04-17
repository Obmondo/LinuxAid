# @summary
#   Contains or define through platform specific sub-classes, the
#   steps for installing the Splunk Universal Forwarder
#
class splunk::forwarder::install {
  $_package_source = $splunk::forwarder::manage_package_source ? {
    true  => $splunk::forwarder::forwarder_package_src,
    false => $splunk::forwarder::package_source
  }

  if $splunk::forwarder::package_provider and !($splunk::forwarder::package_provider in ['apt','chocolatey','yum']) {
    $_src_package_filename = basename($_package_source)
    $_package_path_parts   = [$splunk::forwarder::staging_dir, $_src_package_filename]
    $_staged_package       = join($_package_path_parts, $splunk::forwarder::path_delimiter)

    archive { $_staged_package:
      source         => $_package_source,
      extract        => false,
      allow_insecure => $splunk::forwarder::allow_insecure,
      before         => Package[$splunk::forwarder::package_name],
    }
  } else {
    $_staged_package = undef
  }

  Package {
    source         => $splunk::forwarder::package_provider ? {
      'chocolatey' => undef,
      default      => $splunk::forwarder::manage_package_source ? {
        true  => pick($_staged_package, $_package_source),
        false => $_package_source,
      }
    },
  }

  if $facts['kernel'] == 'SunOS' {
    $_responsefile = "${splunk::forwarder::staging_dir}/response.txt"
    $_adminfile    = '/var/sadm/install/admin/splunk-noask'

    file { 'splunk_adminfile':
      ensure => file,
      path   => $_adminfile,
      owner  => 'root',
      group  => 'root',
      source => 'puppet:///modules/splunk/splunk-noask',
    }

    file { 'splunk_pkg_response_file':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      path    => $_responsefile,
      content => "BASEDIR=/opt\n",
    }

    Package {
      adminfile    => $_adminfile,
      responsefile => $_responsefile,
    }
  }

  # Required for splunk from 7.2.4.2 until 8.0.0
  if (
    $splunk::params::manage_net_tools and
    $facts['kernel'] == 'Linux' and
    versioncmp($splunk::forwarder::version, '7.2.4.2') >= 0 and
    versioncmp($splunk::forwarder::version, '8.0.0') == -1
  ) {
    stdlib::ensure_packages(['net-tools'],
      {
        'ensure' => 'present',
      },
    )
    Package['net-tools'] -> Package[$splunk::forwarder::package_name]
  }

  if $facts['kernel'] == 'Linux' and $facts['service_provider'] == 'systemd' {
    $_splunk_bin = "${splunk::forwarder::forwarder_homedir}/bin/splunk"
    $_splunk_version_cmd = "${_splunk_bin} version 2>/dev/null | head -1 | awk '{print \$2}'"
    $_current_version = inline_template('<%= require "puppet"; facter = @facts; splunk_version = nil; if File.exist?("/opt/splunkforwarder/bin/splunk"); begin; splunk_version = `#{facter["splunkforwarder_version"]}`.strip; rescue; end; end; splunk_version || "0" %>')
    $_needs_upgrade = (versioncmp($_current_version, $splunk::forwarder::version) != 0)

    if $_needs_upgrade {
      exec { 'splunkforwarder-disable-boot-start':
        command => "${_splunk_bin} disable boot-start -user ${splunk::forwarder::splunk_user} --accept-license --answer-yes --no-prompt || true",
        onlyif  => "test -f ${_splunk_bin}",
        timeout => 120,
      }

      exec { 'splunkforwarder-stop-for-upgrade':
        command => "${_splunk_bin} stop",
        onlyif  => "test -f ${_splunk_bin}",
        timeout => 120,
      }
    }

    package { $splunk::forwarder::package_name:
      ensure          => $splunk::forwarder::package_ensure,
      provider        => $splunk::forwarder::package_provider,
      source          => pick($_staged_package, $_package_source),
      install_options => $splunk::forwarder::install_options,
    }

    if $_needs_upgrade {
      exec { 'splunkforwarder-install-rpm':
        command => "/bin/rpm -U --force ${pick($_staged_package, $_package_source)}",
        onlyif  => "test -f ${pick($_staged_package, $_package_source)}",
        timeout => 300,
      }

      exec { 'splunkforwarder-enable-boot-start':
        command => "${_splunk_bin} enable boot-start -user ${splunk::forwarder::splunk_user} --accept-license --answer-yes --no-prompt",
        onlyif  => "test -f ${_splunk_bin}",
        returns => [0, 4],
        timeout => 120,
      }

      Exec['splunkforwarder-disable-boot-start']
        -> Exec['splunkforwarder-stop-for-upgrade']
        -> Package[$splunk::forwarder::package_name]
        -> Exec['splunkforwarder-install-rpm']
        -> Exec['splunkforwarder-enable-boot-start']
    }
  } else {
    package { $splunk::forwarder::package_name:
      ensure          => $splunk::forwarder::package_ensure,
      provider        => $splunk::forwarder::package_provider,
      source          => pick($_staged_package, $_package_source),
      install_options => $splunk::forwarder::install_options,
    }
  }
}
