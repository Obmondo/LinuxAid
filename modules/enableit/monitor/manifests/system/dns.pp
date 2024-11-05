# DNS monitoring
class monitor::system::dns (
  Boolean $enable = true,
) {

  @@monitor::alert { "${title}::resolution":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}
