# Haproxy Config
class eit_haproxy::auto_config (
  Enum[ 'strict', 'strong' ]      $encryption_ciphers,
  Hash                            $letsencrypt_setup   = {},
  Eit_types::HaproxyAuth          $auth                = {},
  Eit_types::HaproxyProxies       $proxies             = {},
  Eit_types::HaproxyListens       $listens             = {},
  Optional[Eit_types::Http::Cors] $cors_font_domain    = undef,
  Optional[Boolean]               $redirect_http       = true,
) {

  # https://wiki.mozilla.org/Security/Server_Side_TLS
  # Strong == Intermediate
  # Strict == Modern
  $_encryption_ciphers = case $encryption_ciphers {
    'strong': {
      'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS' #lint:ignore:140chars
    }
    'strict': {
      'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256' #lint:ignore:140chars
    }
    default: {
      fail("${encryption_ciphers} is not supported")
    }
  }

  $_ssl_bind_options = case $encryption_ciphers {
    'strong': {
      'no-sslv3 no-tls-tickets'
    }
    'strict': {
      'no-sslv3 no-tlsv10 no-tlsv11 no-tls-tickets'
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
      'ssl-default-bind-ciphers'  => $_encryption_ciphers,
      'ssl-default-bind-options'  => $_ssl_bind_options,
      'tune.ssl.default-dh-param' => '2048',
    },
    defaults_options => {
      'log'     => 'global',
      'stats'   => 'enable',
      'option'  => [ 'redispatch' ],
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

  # Setup Frontend and Backend
  $proxies.each |
    $proxy_name,
    $proxy_value,

    # Variables
    $sites          = $proxy_value['sites'],
    $binds          = $proxy_value['binds'],
    $mode           = $proxy_value['mode'],
    $extra_options  = $proxy_value['extra_options'],
    $letsencrypt    = $proxy_value['letsencrypt'],
    $redirect_rules = $proxy_value['redirect_rules'],
  | {

    # Merge the two hashes, if letsencrypt is true
    $_sites = if $letsencrypt { stdlib::merge($letsencrypt_setup,$sites) } else { $sites }

    # Haproxy Frontend
    # Acls
    $_nested_acls = flatten(delete_undef_values($_sites.map |$site, $opts| {
      if ! empty($opts['domains','paths','urls']) {
        # Set the header option
        $_header = case true {
          !empty($opts['header'])  : {$opts['header']}
          !empty($opts['domains']) : {'hdr(host)'}
          !empty($opts['paths'])   : {'path_beg'}
          !empty($opts['urls'])    : {'url_beg'}
          default                  : { fail('Something Wrong with headers') }
        }

        pick($opts['domains'],$opts['paths'],$opts['urls']).map |$endpoint| {
          Hash([
            "acl is_${site}", "${_header} ${endpoint}"
          ])
        }
      }
    }))


    # use_backends
    $_nested_options = flatten(delete_undef_values($_sites.map |$site, $opts| {
      # Set the header option
      $_backend_options = $opts['use_backend_options']

      # Set ssl_fc is true
      $_ssl_fc = unless empty($opts['ssl_fc']) { $opts['ssl_fc'] }

      if ! empty($opts['domains','paths','urls']) {
        $opts['domains','paths','urls'].map |$endpoint| {
          Hash([
            "use_backend ${site}", "if ${_backend_options} is_${site} ${_ssl_fc}"
          ])
        }
      }
    }))

    # binds
    $_binds = pick($binds, { '0.0.0.0' => { ports => [80], }})
    $_nested_binds = eit_haproxy::haproxy_binds($_binds)

    # Default Backend
    # default backend if nothing is set under hiera, we will simply pick the first key under $sites
    $_default_backend_false = [
      Hash([
        'default_backend', Array($sites)[0][0]
      ])
    ]

    # return [] if default_backend is false
    $_default_backend_true = delete_undef_values($sites.map |$site, $opts| {
      if $opts['default_backend'] {
        { 'default_backend' => $site }
      }
    })

    $default_backend = if empty($_default_backend_true) {
      $_default_backend_false
    } else {
      $_default_backend_true
    }

    # Get extra setting from hiera, NOTE: not exposing the extra_settings variable
    $_extra_settings = lookup('eit_haproxy::auto_config::extra_settings').map |$x| {
      { $x => '' }
    }

    # handle all the extra options here
    # currently acl, http_request, redirect_request, no, timeout and log are supported
    $_extra_options = delete_undef_values(flatten([
      if $cors_font_domain {
        Hash([
          'http-request set-var(txn.path)', 'path',
        ])
      },
      $extra_options.map |$key, $opts| {
        $opts.map |$x| {
          { $key => $x }
        }
      }
    ]))

    if $redirect_http {
      # Setup the redirect https rule based on the cert presences.
      $_acl_letsencrypt_http_pending_domain = delete_undef_values(flatten($_sites.map |$site, $opts| {
        if ! empty($opts['domains']) {
          $opts['domains'].map |$domain| {
            if ! $::facts['letsencrypt_directory'][$domain] or $opts['force_https'] == false {
              { 'acl is_unencrypted hdr(host)' => $domain }
            }
          }
        }
      }))

      $_redir_http = [
        {
          'http-request redirect scheme https if !{ ssl_fc }' => [
            if $letsencrypt { '!is_letsencrypt' },
            if $_acl_letsencrypt_http_pending_domain.length > 0 { '!is_unencrypted' },
          ].delete_undef_values.join(' '),
        }
      ]
    }

    $_options = case $mode {
      'http' : {
        if $redirect_http {
          delete_undef_values(union(
            [{'option' => 'httplog'}],
            $_nested_acls,
            $_acl_letsencrypt_http_pending_domain,
            $_extra_settings,
            $_redir_http,
            $_extra_options,
            $_nested_options,
            $default_backend,
          ))
        } else {
          delete_undef_values(union(
            [{'option' => 'httplog'}],
            $_nested_acls,
            $_extra_settings,
            $_extra_options,
            $_nested_options,
            $default_backend,
          ))
        }
      }
      'tcp' : {
        delete_undef_values(union(
          [{'option' => 'tcplog'}],
          $_extra_options,
          $default_backend,
        ))
      }
      default: {
        fail("${mode} is not supported")
      }
    }

    # Frontend Setup
    haproxy::frontend { $proxy_name:
      bind                    => $_nested_binds,
      mode                    => $mode,
      options                 => $_options,
      sort_options_alphabetic => false,
    }

    # Haproxy Backend Setup
    $_sites.map |$site, $opts| {
      $_server_options = $opts.dig('backend_options', 'server_options')
        .then |$x| { join($opts, ', ') }
        .lest || { if $site != 'letsencrypt' { 'check' } }

      $_cors_font_domain = if $cors_font_domain {
        Hash([
          'http-response set-header Access-Control-Allow-Origin',
          "${cors_font_domain} if { var(txn.path) -m end -i .ttf .ttc .otf .eot .woff .woff2 } { status eq 200:299 }",
        ])
      }

      $_extra_options = $opts.dig('backend_options', 'extra_options')
        .then |$x| {
          $x.map |$opts| {
            { $opts => '' }
          }
        }
        .lest || { [] }

      $_nested_backends = $opts['servers'].map |$index, $endpoint| {
        Hash([
          "server ${site}_${index}", "${endpoint} ${_server_options}"
        ])
      }

      $_options = delete_undef_values(union(
        $_extra_options,
        [$_cors_font_domain],
        $_nested_backends,
      ))

      haproxy::backend { $site :
        mode    => $mode,
        options => $_options,
      }
    }
  }

  unless empty($auth) {
    # Create users for HTTP Basic authentication in haproxy
    create_resources('eit_haproxy::users::userlist', {
      auth => $auth,
    })
  }

  # Haproxy Listen block
  $listens.each |$listen_name, $listen_value| {
    $_binds = $listen_value['binds']
    $_mode  = pick($listen_value['mode'],'tcp')
    $_site  = $listen_name

    $_nested_binds = eit_haproxy::haproxy_binds($_binds)

    # Servers
    $_server = flatten($listen_value['servers'].map |$index, $x| {
      Hash([
        "server ${_site}_${index}", "${x} check"
      ])
    })

    haproxy::listen { $listen_name :
      bind    => $_nested_binds,
      mode    => $_mode,
      options => union(
        $_server,
        [{'option' => "${_mode}log"}],
        [$listen_value['extra_options']],
      ),
    }
  }

  # Haproxy Monitoring
  contain eit_haproxy::monitoring

  # Setup logs to send it to rsyslog
  contain eit_haproxy::log
}
