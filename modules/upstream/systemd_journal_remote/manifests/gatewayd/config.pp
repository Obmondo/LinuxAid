# @summary
#   This class configures the systemd-journal-gatewayd unit override
#
# @api private
#
class systemd_journal_remote::gatewayd::config (
  Stdlib::Absolutepath $command_path                     = $systemd_journal_remote::gatewayd::command_path,
  Systemd_Journal_Remote::Gatewayd_Flags $command_flags  = $systemd_journal_remote::gatewayd::command_flags,
  Boolean $manage_service                                = $systemd_journal_remote::gatewayd::manage_service,
  String $service_name                                   = $systemd_journal_remote::gatewayd::service_name,
) {
  assert_private()

  if $manage_service {
    # @fixme A better approach to managing argument variations
    $_options = $command_flags.filter |$key, $value| {
      ($key in ['merge', 'system', 'user'] and $value == true)
    }

    $_flags = $command_flags.filter |$key, $value| {
      $key in ['D']
    }

    $_arguments = $command_flags.filter |$key, $value| {
      ($key in ['D', 'merge', 'system', 'user'] == false)
    }

    # Formatted arguments
    $_command_arguments = [
      $_arguments.join_keys_to_values('=').prefix('--').join(' '),
      $_flags.join_keys_to_values(' ').prefix('-').join(' '),
      $_options.keys.prefix('--').join(' '),
    ].join(' ')

    systemd::dropin_file { "${module_name}-gatewayd_dropin":
      filename => 'service-override.conf',
      unit     => sprintf('%s.service', $service_name),
      content  => epp("${module_name}/gatewayd.service-override.epp", {
          'path'      => $systemd_journal_remote::gatewayd::command_path,
          'arguments' => $_command_arguments,
      }),
      notify   => Service[$service_name],
    }
  }
}
