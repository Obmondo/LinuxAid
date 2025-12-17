#
# Manages Wildfly configuration required to run in service mode.
#
class wildfly::setup {
  wildfly::config::mgmt_user { $wildfly::mgmt_user['username']:
    password => $wildfly::mgmt_user['password'],
  }

  file { "${wildfly::dirname}/jboss.properties":
    ensure  => file,
    owner   => $wildfly::user,
    group   => $wildfly::group,
    content => epp('wildfly/jboss.properties'),
    notify  => Service['wildfly'],
  }

  file { "${wildfly::dirname}/bin/${wildfly::mode}.conf":
    ensure  => file,
    owner   => $wildfly::user,
    group   => $wildfly::group,
    content => epp($wildfly::mode_template),
    notify  => Service['wildfly'],
  }

  if $wildfly::secret_value {
    augeas { 'host_config-secret':
      lens    => 'Xml.lns',
      incl    => "${wildfly::dirname}/${wildfly::mode}/configuration/${wildfly::host_config}",
      changes => "set host/management/security-realms/security-realm[#attribute/name='ManagementRealm']/server-identities/secret/#attribute/value ${wildfly::secret_value}", # lint:ignore:140chars
      onlyif  => "match host/management/security-realms/security-realm[#attribute/name='ManagementRealm']/server-identities/secret[#attribute/value='${wildfly::secret_value}'] size == 0", # lint:ignore:140chars
      notify  => Service['wildfly'],
    }
  }

  if $wildfly::remote_username {
    augeas { 'host_config-remote-username':
      lens    => 'Xml.lns',
      incl    => "${wildfly::dirname}/${wildfly::mode}/configuration/${wildfly::host_config}",
      changes => "set host/domain-controller/remote/#attribute/username ${wildfly::remote_username}",
      onlyif  => "match host/domain-controller/remote[#attribute/username='${wildfly::remote_username}'] size == 0",
      notify  => Service['wildfly'],
    }
  }
}
