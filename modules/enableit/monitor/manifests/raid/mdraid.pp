# MDraid
class monitor::raid::mdraid (
  Boolean $enable = true,
) {

  [
    'degraded',
    'failed'
  ].each |$x| {
    @@monitor::alert { "${name}::${x}":
      enable => $enable,
      tag    => $::trusted['certname'],
    }
  }
}
