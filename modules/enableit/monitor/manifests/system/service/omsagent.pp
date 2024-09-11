# omsagent_updatecheck Checks
class monitor::system::service::omsagent (
  Boolean $enable = true,
) {

  @@monitor::alert { "${title}::update":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}
