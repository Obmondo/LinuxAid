#
# Manages secure management api
#
class wildfly::secure_mgmt_api {
  require wildfly::service

  $mgmt_port = $wildfly::properties['jboss.management.https.port']

  if $wildfly::mgmt_create_keystores {
    if ($wildfly::mgmt_ssl_cert) and ($wildfly::mgmt_ssl_key) {
      $ks_key = $wildfly::mgmt_ssl_key
      $ks_cert  = $wildfly::mgmt_ssl_cert
    }

    else {
      $ks_key = "${wildfly::dirname}/${wildfly::mode}/configuration/mgmt.key"
      $ks_cert = "${wildfly::dirname}/${wildfly::mode}/configuration/mgmt.crt"

      openssl::certificate::x509 { 'mgmt':
        country      => 'WF',
        organization => 'WFMgmt self signed',
        commonname   => $facts['networking']['fqdn'],
        base_dir     => "${wildfly::dirname}/${wildfly::mode}/configuration",
        owner        => $wildfly::user,
        group        => $wildfly::group,
        notify       => Java_ks["${wildfly::mgmt_keystore_alias}:mgmtks"],
      }
    }

    java_ks { "${wildfly::mgmt_keystore_alias}:mgmtks":
      ensure      => latest,
      certificate => $ks_cert,
      private_key => $ks_key,
      target      => $wildfly::mgmt_keystore,
      password    => $wildfly::mgmt_keystore_pass,
      path        => ["${wildfly::java_home}/bin"],
      before      => Exec['Set https management interface'],
    }

    file { $wildfly::mgmt_keystore:
      owner   => $wildfly::user,
      group   => $wildfly::group,
      require => Java_ks["${wildfly::mgmt_keystore_alias}:mgmtks"],
    }

    java_ks { 'cli:truststore':
      ensure      => latest,
      certificate => $ks_cert,
      password    => 'cli_truststore',
      target      => '/root/.jboss-cli.truststore',
      path        => ["${wildfly::java_home}/bin"],
      before      => Exec['Set https management interface'],
    }

    java_ks { 'wfcli:truststore':
      ensure      => latest,
      certificate => $ks_cert,
      password    => 'cli_truststore',
      target      => "/home/${wildfly::user}/.jboss-cli.truststore",
      path        => ["${wildfly::java_home}/bin"],
      before      => Exec['Set https management interface'],
    }

    file { "/home/${wildfly::user}/.jboss-cli.truststore":
      owner   => $wildfly::user,
      group   => $wildfly::group,
      require => Java_ks['wfcli:truststore'],
    }
  }

  exec { 'secure mgmt reload':
    command     => "jboss-cli.sh -c ':reload'; sleep 5",
    refreshonly => true,
    returns     => ['0', '1'],
    path        => ['/bin', '/usr/bin', '/sbin', "${wildfly::dirname}/bin", "${wildfly::java_home}/bin"],
  }

  exec { 'Set https management interface':
    command => "sleep 5; jboss-cli.sh -c '/core-service=management/management-interface=http-interface:write-attribute(name=secure-socket-binding, value=management-https)'", # lint:ignore:140chars
    unless  => "grep -c \'https=\"management-https\"\' ${wildfly::dirname}/${wildfly::mode}/configuration/${wildfly::config}",
    path    => ['/bin', '/usr/bin', '/sbin', "${wildfly::dirname}/bin", "${wildfly::java_home}/bin"],
    before  => Augeas['set_jboss_cli_xml_https'],
  }

  exec { 'Set Realm to use SSL':
    command     => "jboss-cli.sh -c \'/core-service=management/security-realm=ManagementRealm/server-identity=ssl:add(keystore-path=${wildfly::mgmt_keystore},keystore-password=${wildfly::mgmt_keystore_pass},alias=${wildfly::mgmt_keystore_alias}\'", # lint:ignore:140chars
    unless      => "grep -c ${wildfly::mgmt_keystore} ${wildfly::dirname}/${wildfly::mode}/configuration/${wildfly::config}",
    path        => ['/bin', '/usr/bin', '/sbin', "${wildfly::dirname}/bin", "${wildfly::java_home}/bin"],
    environment => "JAVA_HOME=${wildfly::java_home}",
    before      => Augeas['set_jboss_cli_xml_https'],
    subscribe   => Exec['Set https management interface'],
    notify      => Exec['secure mgmt reload'],
  }

  augeas { 'set_jboss_cli_xml_https':
    lens      => 'Xml.lns',
    incl      => "${wildfly::dirname}/bin/jboss-cli.xml",
    changes   => ['set jboss-cli/default-controller/protocol/#text https-remoting',
    "set jboss-cli/default-controller/port/#text ${mgmt_port}"],
    subscribe => Exec['secure mgmt reload'],
  }
}
