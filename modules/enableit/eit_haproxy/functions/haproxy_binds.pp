# Haproxy Binds
# Sample date
# bind 0.0.0.0:443 ssl crt /etc/ssl/private/letsencrypt
# bind 0.0.0.0:80
#
# Example
# eit_haproxy::haproxy_binds({ '0.0.0.0' => { ports => [80], }})
# eit_haproxy::haproxy_binds({ '0.0.0.0' => {
#   ports   => [443],
#   ssl     => true,
#   options => 'crt /etc/ssl/private/readthedocs/combined.pem',
# }})
#
# Output
# {
#   0.0.0.0:80 => []
# }
#
# {
#   0.0.0.0:443 => [
#     'ssl', 'crt /etc/ssl/private/readthedocs/combined.pem'
#   ]
# }

function eit_haproxy::haproxy_binds (
  Hash[
    String,
    Struct[
      {
        ports     => Optional[Variant[Array[Stdlib::Port],Stdlib::Port]],
        ipaddress => Optional[Eit_types::IP],
        ssl       => Optional[Boolean],
        options   => Optional[Variant[String, Array[String]]],
      }
    ]
  ] $binds,
) {

  functions::array_to_hash(flatten($binds.map |$x| {
    $ipaddr = $x[0]
    $opts   = $x[1]

    $_ssl = if $opts['ssl'] { 'ssl' }

    $_options = pick_default($opts['options'])

    $_ipaddress = if type($ipaddr) =~ Type[Eit_types::IP] {
      pick($opts['ipaddress'],$ipaddr)
    } else {
      pick($opts['ipaddress'],'0.0.0.0')
    }

    $opts['ports'].map |$port| {
      # Firewall rules
      ensure_resource('firewall', "${port} - allow haproxy_${_ipaddress}_${port}", {
        proto  => 'tcp',
        dport  => $port,
        jump => 'accept'
      })

      # Return this hash
      Hash([
        "${_ipaddress}:${port}", "${_ssl} ${_options}"
      ])
    }
  }))
}
