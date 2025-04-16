# Docker monitoring
class monitor::system::docker (
  Boolean $enable = true,
) {

  @@monitor::alert { "${title}::status":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}
