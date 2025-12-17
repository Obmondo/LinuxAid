#
# Set external wildflty facts
#
class wildfly::external_facts {
  file { '/opt/puppetlabs/facter/facts.d/wildfly.yaml':
    ensure  => file,
    content => epp('wildfly/facts.yaml'),
  }

  file { '/opt/puppetlabs/facter/facts.d/wildfly_is_running.sh':
    ensure  => file,
    mode    => '1755',
    content => epp('wildfly/wildfly_is_running.sh'),
  }
}
