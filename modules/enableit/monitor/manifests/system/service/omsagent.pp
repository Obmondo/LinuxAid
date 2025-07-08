# @summary Class for monitoring system service 'omsagent' to check for updates
#
# @param enable Boolean flag to enable or disable the update check. Defaults to true.
#
class monitor::system::service::omsagent (
  Boolean $enable = true,
) {
  @@monitor::alert { "${title}::update":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}
