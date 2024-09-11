# SSSD Checks
class monitor::system::service::sssd (
  Boolean $enable = true,
) inherits monitor::system::service {

  contain monitor::system::service::sssd::auth

  @@monitor::alert { "${title}::lookup_failed":
    enable => $enable,
    tag    => $::trusted['certname'],
  }

  @@monitor::alert { "${title}::check":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}
