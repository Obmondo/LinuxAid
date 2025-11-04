class rustdesk::client (
  Boolean            $enable       = $rustdesk::client::enable,
  Eit_types::Version $version      = $rustdesk::client::version,
  Optional[Boolean]  $noop_value   = $rustdesk::client::noop_value,
  Array[String]      $dependencies = $rustdesk::client::dependencies,
) {
  # Fixed common dependencies
  $common_deps = [
    'libxcb-randr0',
    'libxdo3',
    'libxfixes3',
    'libxcb-shape0',
    'libxcb-xfixes0',
    'libva2',
    'libva-drm2',
    'libva-x11-2',
    'libgstreamer-plugins-base1.0-0',
    'gstreamer1.0-pipewire',
  ]

  # Merge common + OS-specific dependencies
  $extra_dependencies = concat($common_deps, $dependencies)

  $package_url   = "https://github.com/rustdesk/rustdesk/releases/download/${version}/rustdesk-${version}-x86_64.deb"
  $package_name  = "rustdesk-${version}-x86_64.deb"
  $download_path = "/tmp/${package_name}"

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

  archive { $download_path:
    ensure => ensure_present($enable),
    source => $package_url,
  }

  package { 'rustdesk':
    ensure   => installed,
    provider => 'dpkg',
    source   => $download_path,
    require  => Archive[$download_path],
  }

  service { 'rustdesk.service':
    ensure  => ensure_service($enable),
    enable  => $enable,
    require => Package['rustdesk'],
  }
}
