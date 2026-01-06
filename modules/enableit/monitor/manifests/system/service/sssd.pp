# @summary Class for managing SSSD checks
#
# @param enable Whether to enable SSSD checks. Defaults to true.
#
# @groups main enable
#
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
