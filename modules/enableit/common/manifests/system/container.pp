# @summary Class for managing the container specifics
#
class common::system::container () inherits common::system {

  # remove mdadm; it installs a `check-raid` cron job that fails and mails
  package::remove('mdadm')
}
