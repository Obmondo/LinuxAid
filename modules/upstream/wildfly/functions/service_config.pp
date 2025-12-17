# Default service configuration for a specific distribution, version
#   execution mode and initsystem.
#
# @param distribution Wildfly distribution: 'wildfly' or 'jboss-eap'.
# @param version Wildfly version.
# @param mode Wildfly execution mode will run, 'standalone' or 'domain'.
# @return [Hash[String, String]] service configuration: name, configuration file and template and bundled init scripts.
function wildfly::service_config(
  String $distribution,
  String $version,
  String $mode,
) {
  case $distribution {
    'wildfly': {
      {
        'service_name'     => 'wildfly',
        'conf_file'        => '/etc/wildfly/wildfly.conf',
        'conf_template'    => 'wildfly/wildfly.systemd.conf',
        'service_file'     => "docs/contrib/scripts/init.d/wildfly-init-${downcase($facts['os']['family'])}.sh",
        'systemd_template' => 'wildfly/wildfly.systemd.service',
      }
    }
    'jboss-eap': {
      {
        'service_name'     => 'jboss-eap',
        'conf_file'        => '/etc/default/jboss-eap.conf',
        'conf_template'    => 'wildfly/wildfly.systemd.conf',
        'service_file'     => 'bin/init.d/jboss-eap-rhel.sh',
        'systemd_template' => 'wildfly/jboss-eap.systemd.service',
      }
    }
    default: {
      fail("Unsupported distribution: ${distribution}")
    }
  }
}
