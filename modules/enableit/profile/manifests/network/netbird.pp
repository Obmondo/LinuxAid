# Netbird Client Setup
# Servers runs on atat
class profile::network::netbird (
  Boolean           $enable     = $common::network::netbird::enable,
  Optional[Boolean] $noop_value = $common::network::netbird::noop_value,
  String            $setup_key  = $common::network::netbird::setup_key,
  Stdlib::HTTPSUrl  $server     = $common::network::netbird::server,
) {

  # Packages are pushed to repos.obmondo.com from netbird repos
  package { 'netbird':
    ensure => ensure_latest($enable),
    noop   => $noop_value,
  }

  if $enable {
    exec { 'netbird up':
      command     => 'netbird up',
      noop        => $noop_value,
      path        => '/usr/bin:/usr/sbin:/bin',
      environment => [
        "NB_SETUP_KEY=${setup_key}",
        "NB_MANAGEMENT_URL=${server}"
      ],
      unless      => "netbird status -d | grep -i 'Management: Connected'",
      require     => Package['netbird'],
    }
  }

  service { 'netbird':
    ensure  => ensure_service($enable),
    noop    => $noop_value,
    require => Package['netbird'],
    notify  => if $enable { Exec['netbird up'] },
  }

  firewall { '0001 allow netbird turn service':
    ensure => ensure_present($enable),
    proto  => 'udp',
    jump   => 'accept',
    dport  => 3478,
  }

  firewall { '0001 allow netbird turn relay connection':
    ensure => ensure_present($enable),
    proto  => 'udp',
    jump   => 'accept',
    dport  => '49152-65535',
  }
}
