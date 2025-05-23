# MOTD
class common::system::motd (
  Boolean           $enable              = true,
  Optional[String]  $header              = undef,
  Optional[String]  $footer              = undef,
  Boolean           $diplay_system_stats = true,
  Optional[Boolean] $noop_value          = undef,
) inherits ::common::system {
  # MOTD
  if $enable {
    $_cores = $facts.dig('processors', 'cores')
    $_threads = $facts.dig('processors', 'threads')
    $_smt_enabled = $_cores != $_threads
    $_stats = {
      memory   => $facts.dig('memory'),
      ip       => $facts.dig('network_primary_ip'),
      vendor   => $facts.dig('dmi','manufacturer'),
      product  => pick($facts.dig('dmi', 'product', 'name'), $facts.dig('dmi','board','product')),
      cpu      => {
        model       => $facts.dig('processors', 'models', 0),
        count       => $facts.dig('physicalprocessorcount'),
        cores       => $_cores,
        threads     => $_threads,
        smt_enabled => $_smt_enabled,

      },
    }

    File {
      noop => $noop_value,
    }

    class { 'motd':
      content  => epp('common/system/motd/motd.epp', {
        header           => $header,
        footer           => $footer,
        stats            => $_stats,
        obmondo_customer => $facts.dig('obmondo_customer'),
      }),
    }
  }


}
