# Haproxy Basic Config Setup
# It can either setup http or tcp mode and not both
# well we can do both, then option would become more complex
class eit_haproxy::basic_config (
  Eit_haproxy::Domains          $domains,
  Eit_haproxy::Listen           $listens            = {},
  Eit_haproxy::Timeout          $frontend_timeout   = {},
  Boolean                       $ddos_protection    = false,
  Boolean                       $https              = true,
  Boolean                       $http               = false,
  Boolean                       $use_hsts           = true,
  Boolean                       $use_lets_encrypt   = true,
  Enum['http','tcp']            $mode               = 'http',
  Array[Stdlib::IP::Address,1]  $listen_on          = ['0.0.0.0'],
  Enum['Modern','Intermediate'] $encryption_ciphers = 'Modern',
) {

  # https://wiki.mozilla.org/Security/Server_Side_TLS
  # Strong == Intermediate
  # Strict == Modern
  $_ssl_options = case $encryption_ciphers {
    'Intermediate': {
      {
        'ssl-default-bind-ciphers' => 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS', #lint:ignore:140chars
        'ssl-default-bind-options' => 'no-sslv3 no-tls-tickets'
      }
    }
    'Modern': {
      {
        'ssl-default-bind-ciphers' => 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256', #lint:ignore:140chars
        'ssl-default-bind-options' => 'no-sslv3 no-tlsv10 no-tlsv11 no-tls-tickets'
      }
    }
    default: {
      fail("${encryption_ciphers} is not supported")
    }
  }

  # Default copied from haproxy::params
  class { 'haproxy':
    global_options   => {
      'log'                       => '127.0.0.1 local0',
      'crt-base'                  => '/etc/ssl/private',
      'chroot'                    => '/var/lib/haproxy',
      'pidfile'                   => '/var/run/haproxy.pid',
      'maxconn'                   => '4000',
      'user'                      => 'haproxy',
      'group'                     => 'haproxy',
      'daemon'                    => '',
      'stats'                     => 'socket /var/run/haproxy.sock mode 600 level admin',
      'tune.ssl.default-dh-param' => '2048',
    } + $_ssl_options,
    defaults_options => {
      'log'     => 'global',
      'stats'   => 'enable',
      'option'  => [
        'redispatch',
        'forwardfor',
      ],
      'retries' => '3',
      'timeout' => [
        'http-request 10s',
        'queue 1m',
        'connect 10s',
        'client 1m',
        'server 1m',
        'check 10s',
      ],
      'maxconn' => '8000',
    }
  }

  $bind_ports = [
    if $https { 443 },
    if $http { 80 },
  ].delete_undef_values

  # Setup firewall rules
  firewall_multi { '100 allow haproxy access':
    dport => $bind_ports,
    proto => 'tcp',
    jump  => 'accept',
  }

  # Setup binds and required haproxy rule
  $binds = functions::array_to_hash($bind_ports.map |$port| {
    $_ssl = if $port == 443 and $mode == 'http' {
      [
        'ssl',
        if $use_lets_encrypt {
          'crt /etc/ssl/private/letsencrypt'
        },
        'crt /etc/ssl/private/static-certs/combined',
      ].delete_undef_values.join(' ')

    }

    $listen_on.map |$listen| {
      Hash([
        "${listen}:${port}", $_ssl
      ])
    }
  })

  if $domains.size {
    # Required Headers
    # If any domains hash map has set force_https to false
    # then we need to add allow_http acl to allow direct http hits
    # as well otherwise haproxy will redirect all traffic to https
    $_allow_http_acl = false in $domains.map |$x, $opts| {
      $opts['force_https']
    }.flatten.delete_undef_values

    $frontend_headers = [
      { 'http-request add-header'  => 'X-Forwarded-Proto https if { ssl_fc }' },
      { 'http-request set-header'  => 'X-Forwarded-Port %[dst_port]' },
      if $use_hsts {
        { 'http-response set-header' => 'Strict-Transport-Security include_subdomains;\ preload;\ max-age=31536000; if { ssl_fc }' }
      },
      { 'http-request redirect scheme https if !{ ssl_fc }' => [
          if $https and $use_lets_encrypt { '!is_letsencrypt' },
          if $_allow_http_acl { '!allow_http' }
        ].delete_undef_values.join(' '),
      }
    ].delete_undef_values

    # Setup the Mapfile.
    $domains_with_backend = $domains.map | $x, $opts | {
      $all_domains = $opts['domains']
      $domain_backend = regsubst($x, /\./, '_', 'G')
      $all_domains.map |$domain| {
        "${domain} ${domain_backend}"
      }
    }.flatten.delete_undef_values.sort

    $alldomains = flatten($domains.map |$x, $opts| {
      $opts['domains']
    })

    $public_ips = lookup('common::settings::publicips', Array, undef, [])

    if $use_lets_encrypt {
      sort_domains_on_tld($alldomains, $public_ips).each |$cn, $san| {
        profile::certs::letsencrypt::domain { $cn:
          domains             => $san,
          deploy_hook_command => '/opt/obmondo/bin/letsencrypt_deploy_hook.sh',
          cert_host           => '0.0.0.0',
        }
      }
    }

    $http_only_domains_options = $domains.values.filter |$_domain_opts| {
      # remove all entries that do not force HTTPS
      !pick($_domain_opts.dig('force_https'), false)
    }.map |$_domain_opts| {
      $_domains = $_domain_opts['domains']
      $_domains.map |$_domain| {
        { 'acl allow_http hdr(host)' => $_domain }
      }
    }.flatten

    if $https and $use_lets_encrypt {
      # letsencrypt backend
      haproxy::backend { 'letsencrypt':
        mode    => 'http',
        options => {
          'server letsencrypt_0' => '127.0.0.1:63480',
        }
      }
    }

    if $mode == 'http' {
      # Frontend
      # NOTE: This class can only setup one frontend for all domains.
      # A seperate backend is created for every domain.

      $prioritized_ips = 'DK.txt'

      $static_exts = '.woff2 .woff .ttf .mp4 .gif .ico .png .jpg .css .js .html .pdf'

      file { '/etc/haproxy/iplists':
        ensure  => directory,
        mode    => '0755',
        recurse => true,
        source  => 'puppet:///modules/eit_haproxy/iplists',
      }

      $ddos_protection_options = [
        # Define a stick table with key = IPv6 address (IPv4 will be translated automatically)
        # and val = number of HTTP requests made in 10s.
        { 'stick-table'   => 'type ipv6 size 100k expire 10s store http_req_rate(10s)' },
        # ACL which is true for URLs that point to static files.
        { 'acl'  => "is_static_content path_end ${static_exts}" },
        # Keep track of all requests in sticky counter 0 of the above table.
        { 'http-request'  => 'track-sc0 src if !is_static_content' },
        # ACL which is true if source IP belongs to the priority list.
        { 'acl'  => "is_priority src -f /etc/haproxy/iplists/${prioritized_ips}" },
        # ACLs which return true if source IP crosses their rate limit,
        # measured against sticky counter 0 of above table.
        { 'acl'  => 'priority_rl_reached sc_http_req_rate(0) gt 600' },
        { 'acl'  => 'ww_rl_reached sc_http_req_rate(0) gt 250' },
        # If source is in the prioritized ip range, then follow the prioritized rate limit.
        { 'http-request'  => 'deny deny_status 429 if is_priority priority_rl_reached' },
        # If source is not from a prioritized ip (rest of the world) then follow the worldwide rate limit.
        { 'http-request'  => 'deny deny_status 429 if !is_priority ww_rl_reached' },
      ]

      $_frontend_timeout = Hash(
        $frontend_timeout.map |$k, $v| {
          ["timeout ${k}", $v]
        }
      )

      haproxy::frontend { 'web':
        mode    => $mode,
        bind    => $binds,
        options => [
          {'option' => "${mode}log"},
          $_frontend_timeout,
          if $https and $use_lets_encrypt {
            { 'acl is_letsencrypt' => 'path_beg /.well-known/acme-challenge/' }
          },
          $http_only_domains_options,
          $frontend_headers,
          if $ddos_protection {
            $ddos_protection_options
          },
          if $https and $use_lets_encrypt {
            [{'use_backend letsencrypt' => 'if is_letsencrypt'}]
          },
          [{'use_backend' => '%[req.hdr(host),lower,map(/etc/haproxy/domains-to-backends.map)]'}]
        ].delete_undef_values.flatten,
      }

      haproxy::mapfile { 'domains-to-backends':
        ensure   => 'present',
        mappings => $domains_with_backend
      }

      $domains.each | $domain, $opts | {
        $domain_backend = regsubst($domain, /\./, '_', 'G')
        $extra_options  = if $opts['extra_opts'] {
                            $opts['extra_opts']
                          }
                          else {
                            'check'
                          }
        # Setup the Backend
        haproxy::backend { $domain_backend:
          mode    => $mode,
          options => $opts['servers'].map |$index, $endpoint| {
            { "server ${domain_backend}_${index}" => "${endpoint} ${extra_options}" }
          }
        }
      }
    }
  }

  # Haproxy Monitoring
  contain eit_haproxy::monitoring

  $listens.each |$key, $value| {
    $_servers = $value['servers'].map |$server| {
      "${key} ${server} check"
    }

    $_bind_options = $value['bind_options'].empty ? {
      true  => [],
      false => $value['bind_options'],
    }

    $bind = $value['binds'].reduce({}) |$acc, $x| {
      if $value['force_https'] {
        $acc + {
          $x => [],
        } + {
          "${x} ${value['bind_options'].join(' ')}" => [],
        }
      } else {
        $acc + {
          $x => $value['bind_options'],
        }
      }
    }

    haproxy::listen { $key:
      mode    => $mode,
      bind    => $bind,
      options => {
        'option'                => 'tcplog',
        'balance'               => 'roundrobin',
        'http-request redirect' => if $value['force_https'] { 'scheme https code 301 unless { ssl_fc }' },
        'server'                => $_servers,
        'timeout'               => 'server 10m',
      },
    }
  }
}
