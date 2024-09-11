# @summary This is a simple controller class for global settings related to the
# `reboot_notify` custom type
#
# @param log_level
#   The Puppet log_level to use when generating output
#
#   To change the level of the reboot_notify messages add this class
#   to the class list in hiera and set simplib::reboot_notify::log_level to
#   the level you want.
#
#   * Set to  log_level to``debug`` if you wish to disable output unless you're
#     running in debug mode.
#
class simplib::reboot_notify (
  Simplib::PuppetLogLevel $log_level = 'notice'
){
  reboot_notify { '__simplib_control__':
    log_level    => $log_level,
    control_only => true
  }
}
