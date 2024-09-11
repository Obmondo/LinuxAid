# @!visibility private
class rngd::service {

  $hasstatus = $::rngd::hasstatus
  $pattern   = $hasstatus ? {
    false   => 'rngd',
    default => undef,
  }

  if $::rngd::service_manage {
    service { $::rngd::service_name:
      ensure     => running,
      enable     => true,
      hasstatus  => $hasstatus,
      hasrestart => true,
      pattern    => $pattern,
    }
  }
}
