# apply defaults
#
class logrotate::defaults (
  $create_base_rules = $logrotate::create_base_rules,
  $rules             = $logrotate::params::base_rules,
  $rule_default      = $logrotate::params::rule_default
) {
  assert_private()

  if !defined( Logrotate::Conf[$logrotate::params::config_file]) {
    logrotate::conf { $logrotate::params::config_file:
      * => $logrotate::params::conf_params,
    }
  }

  if $create_base_rules {
    $rules.each |$rule_name, $params| {
      if !defined(Logrotate::Rule[$rule_name]) {
        $_merged_params = $rule_default + $params
        logrotate::rule { $rule_name:
          * => $_merged_params,
        }
      }
    }
  }
}
