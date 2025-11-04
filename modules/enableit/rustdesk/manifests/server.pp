class rustdesk::server (
  Boolean            $enable       = $rustdesk::server::enable,
  Eit_types::Version $version      = $rustdesk::server::version,
  Optional[Boolean]  $noop_value   = $rustdesk::server::noop_value,
  Array[String]      $dependencies = $rustdesk::server::dependencies,
) {
  # Fixed common dependencies
  $common_deps = []

  # Merge common + OS-specific dependencies
  $extra_dependencies = concat($common_deps, $dependencies)

  $relay_server_package_url   = "https://github.com/rustdesk/rustdesk-server-pro/releases/download/${version}/rustdesk-server-hbbr_${version}_amd64.deb"
  $relay_server_package_name  = "rustdesk-server-hbbr_${version}_amd64.deb"
  $relay_server_download_path = "/tmp/${relay_server_package_name}"

  $signal_server_package_url   = "https://github.com/rustdesk/rustdesk-server-pro/releases/download/${version}/rustdesk-server-hbbs_${version}_amd64.deb"
  $signal_server_package_name  = "rustdesk-server-hbbs_${version}_amd64.deb"
  $signal_server_download_path = "/tmp/${signal_server_package_name}"

  $packages = ['relay', 'signal']

  Package {
    noop => $noop_value,
  }

  Exec {
    noop => $noop_value,
  }

  Service {
    noop => $noop_value,
  }

  # Ensure dependencies are installed first
  package { $extra_dependencies:
    ensure => installed,
  }

  # ----------------

  $packages.each |$pkg| {
    # Here you can define what you want to do with each package
    notify { "Installing package: ${package}":
      message => "Installing ${package}",
    }

    archive { $pkg$relay_server_download_path:
      ensure => ensure_present($enable),
      source => $relay_server_package_url,
    }

    package { 'rustdesk-server-hbbr':
      ensure   => installed,
      provider => 'dpkg',
      source   => $relay_server_download_path,
      require  => Archive[$relay_server_download_path],
    }

    service { 'rustdesk-hbbr.service':
      ensure  => ensure_service($enable),
      enable  => $enable,
      require => Package['rustdesk-server-hbbr'],
    }
  }

  # ----------------

  archive { $relay_server_download_path:
    ensure => ensure_present($enable),
    source => $relay_server_package_url,
  }

  package { 'rustdesk-server-hbbr':
    ensure   => installed,
    provider => 'dpkg',
    source   => $relay_server_download_path,
    require  => Archive[$relay_server_download_path],
  }

  service { 'rustdesk-hbbr.service':
    ensure  => ensure_service($enable),
    enable  => $enable,
    require => Package['rustdesk-server-hbbr'],
  }

  # ----------------

  archive { $signal_server_download_path:
    ensure => ensure_present($enable),
    source => $signal_server_package_url,
  }

  package { 'rustdesk-server-hbbr':
    ensure   => installed,
    provider => 'dpkg',
    source   => $signal_server_download_path,
    require  => Archive[$signal_server_download_path],
  }

  service { 'rustdesk-hbbr.service':
    ensure  => ensure_service($enable),
    enable  => $enable,
    require => Package['rustdesk-server-hbbr'],
  }
}
