# @summary
#   This class configures the [Upload] section of journal-upload.conf
#
# @api private
#
class systemd_journal_remote::upload::config (
  Stdlib::Absolutepath $command_path                   = $systemd_journal_remote::upload::command_path,
  Systemd_Journal_Remote::Upload_Flags $command_flags  = $systemd_journal_remote::upload::command_flags,
  Boolean $manage_service                              = $systemd_journal_remote::upload::manage_service,
  Systemd_Journal_Remote::Upload_Options $options      = $systemd_journal_remote::upload::options,
  String $service_name                                 = $systemd_journal_remote::upload::service_name,
) {
  assert_private()

  $options.each |$setting, $value| {
    ini_setting { "${module_name}-journal_upload_${setting}":
      path    => '/etc/systemd/journal-upload.conf',
      section => 'Upload',
      setting => $setting,
      value   => $value,
      notify  => Service[$service_name],
    }
  }

  if $manage_service {
    # @fixme A better approach to managing argument variations
    $_options = $command_flags.filter |$key, $value| {
      ($key in ['merge', 'system', 'user'] and $value == true)
    }

    $_flags = $command_flags.filter |$key, $value| {
      $key in ['D', 'u']
    }

    $_arguments = $command_flags.filter |$key, $value| {
      ($key in ['D', 'merge', 'system', 'u', 'user'] == false)
    }

    # Formatted arguments
    $_command_arguments = [
      $_arguments.join_keys_to_values('=').prefix('--').join(' '),
      $_flags.join_keys_to_values(' ').prefix('-').join(' '),
      $_options.keys.prefix('--').join(' '),
    ].join(' ')

    systemd::dropin_file { "${module_name}-upload_dropin":
      filename => 'service-override.conf',
      unit     => sprintf('%s.service', $service_name),
      content  => epp("${module_name}/upload.service-override.epp", {
          'path'      => $command_path,
          'arguments' => $_command_arguments,
      }),
      notify   => Service[$service_name],
    }
  }
}
