# @summary Class for managing the Jenkins CI role
#
# Jenkins listens on localhost:8080 and is published through
# role::web::haproxy, so configure it with role::web::haproxy::* in hiera,
# e.g. role::web::haproxy::domains with servers ['127.0.0.1:8080'].
#
# @param version The version of Jenkins to install. Defaults to 'installed'.
#
# @param config_hash A hash of configuration parameters. Defaults to an empty hash.
#
# @param plugins A hash of Jenkins plugins to install, including their required
#   dependencies (they are not resolved automatically). Hash-merged with the
#   baseline in data/role/role::ci::jenkins.yaml (configuration-as-code,
#   matrix-auth and their dependencies).
#
# @param casc_config Jenkins Configuration as Code (JCasC) settings, e.g. an
#   LDAP/AD security realm and permission matrix. Passed to jenkins::casc_config,
#   which writes it to /var/lib/jenkins/jenkins.yaml. Needs the
#   configuration-as-code plugin in plugins. Defaults to an empty hash (not managed).
#
# @groups jenkins_info version, config_hash, plugins
#
# @groups configuration_as_code casc_config
#
class role::ci::jenkins (
  Eit_types::Version          $version          = 'installed',
  Hash                        $config_hash      = {},
  Eit_types::Jenkins::Plugins $plugins          = {},
  Hash                        $casc_config      = {},
) {
  class { 'profile::ci::jenkins':
    version     => $version,
    config_hash => $config_hash,
    plugins     => $plugins,
    casc_config => $casc_config,
  }

  contain role::web::haproxy
}
