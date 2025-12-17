#
# Configures a log category
#
# @param level Log level
# @param use_parent_handlers Wheter to use parent handlers or not
# @param handlers List of log handlers to use
# @param target_profile For domain mode you need to set this parameter
#
define wildfly::logging::category (
  Enum['DEBUG', 'INFO', 'ERROR'] $level               = 'INFO',
  Boolean                        $use_parent_handlers = false,
  Optional[Array[String[1]]]     $handlers            = undef,
  Optional[String]               $target_profile      = undef,
) {
  $params = {
    'level'               => $level,
    'use-parent-handlers' => $use_parent_handlers,
    'handlers'            => $handlers,
  }

  wildfly::resource { "/subsystem=logging/logger=${title}":
    content => $params,
    profile => $target_profile,
  }
}
