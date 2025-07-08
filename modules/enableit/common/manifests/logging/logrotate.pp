# @summary Class for managing logrotate rules
#
# @param manage Boolean flag to determine whether to manage logrotate rules. Defaults to false.
#
# @param purge Boolean flag to determine whether to purge existing rules. Defaults to false.
#
# @param dateext Boolean to enable date extension in logrotate filenames. Defaults to true.
#
# @param compress Boolean to enable compression of rotated logs. Defaults to true.
#
# @param su Boolean indicating whether to use 'su' directive. Defaults to true (note: not supported).
#
# @param rules Hash of custom logrotate rules. Defaults to empty hash.
#
class common::logging::logrotate (
  Boolean $manage   = false,
  Boolean $purge    = false,
  Boolean $dateext  = true,
  Boolean $compress = true,
  Boolean $su       = true,
  Eit_types::Common::Logging::Logrotate::Rules $rules = {},
) inherits ::common::logging {
  # su directive is not supported.
  confine($facts['os']['family'] == 'RedHat',
          $facts['os']['release']['major'] == '6',
          $su == true,
          'su logrotate directive is not support on this platform')
  # Ensure that we don't try to use a config that is invalid on this platform
  confine($facts['os']['family'] == 'RedHat',
          $facts['os']['release']['major'] == '6',
          !($rules.values.filter |$r| {
            $r.dig('su_owner') or $r.dig('su_group')
          }.empty),
          '`su_group` and `su_owner` are not valid on this platform')
  # Ensure that we don't try to use a config that is invalid on this platform
  confine($facts['os']['family'] == 'RedHat',
          !($rules.values.filter |$r| {
            $r.dig('minage')
          }.empty),
          '`minage` is not valid on this platform')
  # TODO: handle removal of custom thing, which we install
  if $manage {
    include ::profile::logging::logrotate
  }
}
