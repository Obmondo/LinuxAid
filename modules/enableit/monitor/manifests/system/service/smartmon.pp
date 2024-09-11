# Smartmon Checks
class monitor::system::service::smartmon (
  Boolean $enable = false,
) inherits monitor::system::service {

  @@monitor::alert { "${title}::disk_healthy":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}
