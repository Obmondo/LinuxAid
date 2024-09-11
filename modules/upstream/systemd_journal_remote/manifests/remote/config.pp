# @summary
#   This class configures the [Remote] section of journal-remote.conf
#
# @api private
#
class systemd_journal_remote::remote::config (
  Stdlib::Absolutepath $command_path                     = $systemd_journal_remote::remote::command_path,
  Systemd_Journal_Remote::Remote_Flags $command_flags    = $systemd_journal_remote::remote::command_flags,
  Boolean $manage_service                                = $systemd_journal_remote::remote::manage_service,
  Systemd_Journal_Remote::Remote_Options $options        = $systemd_journal_remote::remote::options,
  String $service_name                                   = $systemd_journal_remote::remote::service_name,
) {
  assert_private()

  $options.each |$setting, $value| {
    ini_setting { "${module_name}-journal_remote_${setting}":
      path    => '/etc/systemd/journal-remote.conf',
      section => 'Remote',
      setting => $setting,
      value   => $value,
      notify  => Service[$service_name],
    }
  }

  if $manage_service {
    systemd::dropin_file { "${module_name}-remote_dropin":
      filename => 'service-override.conf',
      unit     => sprintf('%s.service', $service_name),
      content  => epp("${module_name}/remote.service-override.epp", {
        'command_path'  => $command_path,
        'command_flags' => $command_flags,
      }),
      notify   => Service[$service_name],
    }
  }
}
