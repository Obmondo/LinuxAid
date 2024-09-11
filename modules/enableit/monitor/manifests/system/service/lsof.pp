#  Checks temperory deleted files
class monitor::system::service::lsof (
  Boolean $enable = true,
) inherits monitor::system::service {

  @@monitor::alert { "${title}::open_deleted_file":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}
