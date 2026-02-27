# Haproxy Basic Config Setup
# It can either setup http or tcp mode and not both
# well we can do both, then option would become more complex
class eit_haproxy::basic_config (
  Eit_haproxy::Domains          $domains,
  Eit_haproxy::Listen           $listens            = {},
  Boolean                       $ddos_protection    = false,
  Boolean                       $https              = true,
  Boolean                       $http               = false,
  Boolean                       $use_hsts           = true,
  Boolean                       $use_lets_encrypt   = true,
  Enum['http','tcp']            $mode               = 'http',
  Array[Stdlib::IP::Address,1]  $listen_on          = ['0.0.0.0'],
  Enum['Modern','Intermediate'] $encryption_ciphers = 'Modern',
  Eit_types::Package_version    $version            = 'latest',
  Boolean                       $use_native_acme    = $eit_haproxy::use_native_acme,
  String                        $acme_contact       = $eit_haproxy::acme_contact,
  String                        $acme_directory     = $eit_haproxy::acme_directory,
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

  $_native_acme_global_options = if $use_native_acme {
    {
      'expose-experimental-directives'  => '',
      'ssl-default-bind-ciphersuites'   => 'TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256',
    }
  } else {
    {}
  }

  # Default copied from haproxy::params
  class { 'haproxy':
    package_ensure  => $version,
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
    } + $_ssl_options + $_native_acme_global_options,
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

  if $use_native_acme {
    concat::fragment { 'haproxy_acme_section':
      target  => $haproxy::config_file,
      order   => '12-acme',
      content => epp('eit_haproxy/acme_section.epp', {
          'contact'   => $acme_contact,
          'directory' => $acme_directory,
      }),
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

  $web_bind_ports = [
    if $https { 443 },
    if $http and !$use_native_acme { 80 },
  ].delete_undef_values

  # Setup binds and required haproxy rule
  $binds = functions::array_to_hash($web_bind_ports.map |$port| {
      $_ssl = if $port == 443 and $mode == 'http' {
        if $use_native_acme {
          'ssl crt /etc/ssl/private/haproxy-dummy.pem alpn h2,http/1.1 strict-sni'
        } else {
          [
            'ssl',
            if $use_lets_encrypt {
              'crt /etc/ssl/private/letsencrypt'
            },
            'crt /etc/ssl/private/static-certs/combined',
          ].delete_undef_values.join(' ')
        }
      }

      $listen_on.map |$listen| {
        Hash([
            "${listen}:${port}", $_ssl,
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
          if $https and $use_lets_encrypt and !$use_native_acme { '!is_letsencrypt' },
          if $_allow_http_acl { '!allow_http' },
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

    if $use_lets_encrypt and !$use_native_acme {
      sort_domains_on_tld($alldomains, $public_ips).each |$cn, $san| {
        profile::certs::letsencrypt::domain { $cn:
          domains             => $san,
          deploy_hook_command => '/opt/obmondo/bin/letsencrypt_deploy_hook.sh',
          cert_host           => '0.0.0.0',
        }
      }
    }

    if $use_native_acme {
      # Add Native ACME Monitoring which will loop and directly call monitor::domains
      sort_domains_on_tld($alldomains, $public_ips).each |$cn, $san| {
        monitor::domains { $cn:
          enable => true,
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

    if $https and $use_lets_encrypt and !$use_native_acme {
      # letsencrypt backend
      haproxy::backend { 'letsencrypt':
        mode    => 'http',
        options => {
          'server letsencrypt_0' => '127.0.0.1:63480',
        },
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

      $_native_acme_frontend_options = if $use_native_acme {
        $domains.filter |$group_name, $opts| {
          if $opts['force_https'] { true } else { false }
        }.map |$group_name, $opts| {
          $_all_domains_in_group = $opts['domains'].join(',')
          $_cert_filename = regsubst($group_name, /[^a-zA-Z0-9.-]/, '_', 'G')
          Hash(['ssl-f-use', "crt /etc/ssl/private/${_cert_filename}.pem acme LE domains ${_all_domains_in_group}"])
        }
      } else {
        []
      }

      haproxy::frontend { 'web':
        mode    => $mode,
        bind    => $binds,
        options => [
          { 'option' => "${mode}log" },
          if $https and $use_lets_encrypt and !$use_native_acme {
            { 'acl is_letsencrypt' => 'path_beg /.well-known/acme-challenge/' }
          },
          $http_only_domains_options,
          $frontend_headers,
          if $ddos_protection {
            $ddos_protection_options
          },
          if $https and $use_lets_encrypt and !$use_native_acme {
            [{ 'use_backend letsencrypt' => 'if is_letsencrypt' }]
          },
          $_native_acme_frontend_options,
          [{ 'use_backend' => '%[req.hdr(host),lower,map(/etc/haproxy/domains-to-backends.map)]' }]
        ].delete_undef_values.flatten,
      }

      if $use_native_acme {
        haproxy::frontend { 'acme':
          mode    => 'http',
          bind    => functions::array_to_hash($listen_on.map |$listen| {
              Hash(["${listen}:80", []])
          }),
          options => [
            { 'http-request' => 'return status 200 content-type text/plain lf-string "%[path,field(-1,/)].%[path,field(-1,/),map(virt@acme)]\n" if { path_beg \'/.well-known/acme-challenge/\' }' },
            { 'http-request redirect scheme https' => [
                if $_allow_http_acl { '!allow_http' },
              ].delete_undef_values.join(' '),
            },
            $http_only_domains_options,
            [{ 'use_backend' => '%[req.hdr(host),lower,map(/etc/haproxy/domains-to-backends.map)]' }]
          ].delete_undef_values.flatten,
        }
      }

      haproxy::mapfile { 'domains-to-backends':
        ensure   => 'present',
        mappings => $domains_with_backend,
      }

      $domains.each | $domain, $opts | {
        $domain_backend = regsubst($domain, /\./, '_', 'G')
        $extra_options = pick($opts['extra_opts'], 'check')

        # Setup the Backend
        haproxy::backend { $domain_backend:
          mode    => $mode,
          options => $opts['servers'].map |$index, $endpoint| {
            { "server ${domain_backend}_${index}" => "${endpoint} ${extra_options}" }
          },
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
