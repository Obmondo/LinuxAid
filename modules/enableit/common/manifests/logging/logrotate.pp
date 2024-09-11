# logrotate rules
class common::logging::logrotate (
  Boolean $manage   = false,
  Boolean $purge    = false,
  Boolean $dateext  = true,
  Boolean $compress = true,
  Boolean $su       = true,

  Eit_types::Common::Logging::Logrotate::Rules $rules = {},
) inherits ::common::logging {

  # su directive is not supported.
  confine($facts.dig('os', 'family') == 'RedHat',
          $facts.dig('os', 'release', 'major') == '6',
          $su == true,
          'su logrotate directive is not support on this platform')

  # Ensure that we don't try to use a config that is invalid on this platform
  confine($facts.dig('os', 'family') == 'RedHat',
          $facts.dig('os', 'release', 'major') == '6',
          !($rules.values.filter |$r| {
            $r.dig('su_owner') or $r.dig('su_group')
          }.empty),
          '`su_group` and `su_owner` are not valid on this platform')

  # Ensure that we don't try to use a config that is invalid on this platform
  confine($facts.dig('os', 'family') == 'RedHat',
          !($rules.values.filter |$r| {
            $r.dig('minage')
          }.empty),
          '`minage` is not valid on this platform')

  # TODO: handle removal of custom thing, which we install
  if $manage {
    include ::profile::logging::logrotate
  }

}
