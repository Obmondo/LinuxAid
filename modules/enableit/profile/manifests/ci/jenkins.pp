# jenkins profile
class profile::ci::jenkins (
  Eit_types::Version          $version     = 'installed',
  Hash                        $config_hash = {},
  Eit_types::Jenkins::Plugins $plugins     = {},
  Stdlib::Port                $port        = 8080,
  Hash                        $casc_config = {},
) inherits ::profile {

  # The Jenkins repo and its signing key are managed by eit_repos, since
  # puppet/jenkins still ships the expired jenkins.io-2023.key.
  eit_repos::repo { 'jenkins': }

  Yumrepo <| title == 'jenkins' |> -> Class['jenkins']
  Apt::Source <| title == 'jenkins' |> -> Class['jenkins']

  # Current Jenkins LTS needs Java 17+, but puppet/jenkins' java module would
  # install Java 8 on EL. Install Java 21 here instead (install_java => false).
  case $facts['os']['family'] {
    'Debian': {
      package::install('openjdk-21-jre-headless', { before => Class['jenkins'] })
    }
    default: {
      package::install('java-21-openjdk-headless', { before => Class['jenkins'] })
    }
  }

  class { 'jenkins':
    version        => $version,
    lts            => true,
    repo           => false,
    install_java   => false,
    port           => $port,
    service_enable => true,
    config_hash    => $config_hash,
    localstatedir  => '/var/lib/jenkins',
    user           => 'jenkins',
    manage_user    => true,
    group          => 'jenkins',
    manage_group   => true,
    casc_config    => $casc_config,
  }

  $plugins.each |$_plugin, $_settings| {
    jenkins::plugin { $_plugin:
      * => $_settings,
    }
  }
}
