# Post firewall
class std_fw::post (
  Boolean        $drop_all    = true,
  Std_fw::Action $drop_action = 'drop',
) {

  Firewall {
    before => undef,
  }

  firewall { '998 log all':
    proto     => 'all',
    jump      => 'LOG',
    log_level => 'debug',
  }

  if $drop_all {
    firewall { '999 drop all':
      proto  => 'all',
      jump => $drop_action,
    }
  }
}
