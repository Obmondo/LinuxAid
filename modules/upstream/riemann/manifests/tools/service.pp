class riemann::tools::service {
  service {'riemann-health':
    ensure     => running,
    enable     => $riemann::tools::health_enabled,
    hasrestart => true,
    provider   => systemd,
  }

  service {'riemann-net':
    ensure     => running,
    enable     => $riemann::tools::net_enabled,
    hasrestart => true,
    provider   => systemd,
  }
}
