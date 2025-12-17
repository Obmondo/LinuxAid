# Default OS configuration for a specific distribution and version.
#
# @param distribution Wildfly distribution: 'wildfly' or 'jboss-eap'.
# @param version Wildfly version.
# @return [Hash[String, String]] OS configuration: user, group, dirname and console_log.
function os_config(
  String $distribution,
  String $version,
) {
  case $distribution {
    'jboss-eap': {
      case [versioncmp($version, '7')] {
        [-1]: {
          {
            'user'        => 'jboss-as',
            'group'       => 'jboss-as',
            'dirname'     => '/opt/jboss-as',
            'console_log' => '/var/log/jboss-as/console.log',
          }
        }
        [default]: {
          {
            'user'        => 'jboss-eap',
            'group'       => 'jboss-eap',
            'dirname'     => '/opt/jboss-eap',
            'console_log' => '/var/log/jboss-eap/console.log',
          }
        }
      }
    }
    default: {
      {
        'user'        => 'wildfly',
        'group'       => 'wildfly',
        'dirname'     => '/opt/wildfly',
        'console_log' => '/var/log/wildfly/console.log',
      }
    }
  }
}
