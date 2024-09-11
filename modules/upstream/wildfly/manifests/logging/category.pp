#
# Configures a log category
#
define wildfly::logging::category($level = undef, $use_parent_handlers = undef, $handlers = undef, $target_profile = undef) {

  $params = {
    'level'                => $level,
    'use-parent-handlers'  => $use_parent_handlers,
    'handlers'             => $handlers
  }

  wildfly::util::resource { "/subsystem=logging/logger=${name}":
    content => $params,
    profile => $target_profile,
  }

}
