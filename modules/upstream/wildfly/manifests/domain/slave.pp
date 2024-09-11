define wildfly::domain::slave($secret, $domain_master_address) {

  augeas { $name:
    lens    => 'Xml.lns',
    incl    => "${wildfly::dirname}/${wildfly::mode}/configuration/${wildfly::host_config}",
    changes => "set host/#attribute/name ${name}",
    onlyif  => "match host[#attribute/name='${name}'] size == 0"
  }

  augeas { "${name}-secret":
    lens    => 'Xml.lns',
    incl    => "${wildfly::dirname}/${wildfly::mode}/configuration/${wildfly::host_config}",
    changes => "set host/management/security-realms/security-realm[#attribute/name='ManagementRealm']/server-identities/secret/#attribute/value ${secret}",
    onlyif  => "match host/management/security-realms/security-realm[#attribute/name='ManagementRealm']/server-identities/secret[#attribute/value='${secret}'] size == 0"
  }

  augeas { "${name}-host":
    lens    => 'Xml.lns',
    incl    => "${wildfly::dirname}/${wildfly::mode}/configuration/${wildfly::host_config}",
    changes => "set host/domain-controller/remote/#attribute/host ${domain_master_address}",
    onlyif  => "match host/domain-controller/remote[#attribute/host='${domain_master_address}'] size == 0"
  }

}