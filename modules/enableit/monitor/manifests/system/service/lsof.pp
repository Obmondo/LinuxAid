# @summary Class for managing the monitor::system::service::lsof resource
#
# @param enable 
# Whether to enable monitoring of open deleted files. Defaults to true.
#
class monitor::system::service::lsof (
  Boolean $enable = true,
) inherits monitor::system::service {

  @@monitor::alert { "${title}::open_deleted_file":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}
