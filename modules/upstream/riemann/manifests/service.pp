class riemann::service (
  Boolean $enable,
) {
  service {'riemann':
    ensure     => ensure_service($enable),
    enable     => $enable,
  }
}
