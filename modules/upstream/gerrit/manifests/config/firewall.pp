# == Class: gerrit::config::firewall
#
# This class configures the firewall for Gerrit
#
# === Parameters
#
# This class accepts no parameters directly
#
# === Variables
#
# This class accepts no variables directly
#
# === Authors
#
# Andrew Grimberg <agrimberg@linuxfoundation.org>
#
# === Copyright
#
# Copyright 2015 Andrew Grimberg
#
class gerrit::config::firewall {
  if ($gerrit::manage_firewall) {
    $options = $gerrit::options

    if ( has_key($options, 'httpd') ) {
      if ( has_key($options['httpd'], 'listenUrl') ) {
        $listenUrl = $options['httpd']['listenUrl']
      }
      else {
        # set the listenUrl to the default
        $listenUrl = 'http://*:8080'
      }
    }
    else {
        # set the listenUrl to the default
        $listenUrl = 'http://*:8080'
    }

    if ( has_key($options, 'sshd') ) {
      if ( has_key($options['sshd'], 'listenAddress') ) {
        $listenAddress = $options['sshd']['listenAddress']
      }
      else {
        # set the listenAddress to the default
        $listenAddress = '*:29418'
      }
    }
    else {
      # set the listenAddress to the default
      $listenAddress = '*:29418'
    }

    $listenUrl_arr = split($listenUrl, '[:/]')
    $listenUrl_port = $listenUrl_arr[4]
    $listenUrl_addr = $listenUrl_arr[3]

    case $listenUrl_addr {
      '*':      { $listenUrl_destination = undef }
      default:  { $listenUrl_destination = $listenUrl_addr }
    }

    $listenAddress_arr = split($listenAddress, ':')
    $listenAddress_port = $listenAddress_arr[1]
    $listenAddress_addr = $listenAddress_arr[0]

    case $listenAddress_addr {
      '*':      { $listenAddress_destination = undef }
      default:  { $listenAddress_destination = $listenAddress_addr }
    }

    firewall{'050 gerrit webui access':
      proto       => 'tcp',
      state       => ['NEW'],
      action      => 'accept',
      port        => [$listenUrl_port],
      destination => $listenUrl_destination,
    }

    firewall{'050 gerrit ssh access':
      proto       => 'tcp',
      state       => ['NEW'],
      action      => 'accept',
      port        => [$listenAddress_port],
      destination => $listenAddress_destination,
    }
  }
}
