# @summary HAProxy 3.x native ACME — placeholder certs and crt-list assembly.
#
# For each managed domain group:
#   1. Generates a self-signed placeholder cert via openssl::certificate::x509
#      at $_acme_dir/<sanitised>.{crt,key} (puppet-managed source material).
#   2. An exec concatenates cert+key into $_pem_dir/<sanitised>.pem (HAProxy's
#      expected format). `creates =>` makes it idempotent — the .pem is never
#      rebuilt once it exists, which protects real LE certs that
#      haproxy-dump-certs.sh later writes back to the same path.
#   3. The crt-list is rendered as a single file from an EPP template,
#      binding each PEM to the `acme LE` section.
#
# How issuance happens:
#   - HAProxy runs with `acme.scheduler off` (basic_config.pp). Its own
#     scheduler starts every due cert in the same pass, which sends hundreds
#     of orders to LE at once on a large host.
#   - haproxy-acme-renew.sh renews certs that expire within $renew_days days,
#     one a minute, and dumps each to disk. It runs every 12 hours and on
#     every haproxy start, so a new domain gets its cert right after the
#     restart.
#   - The placeholder is born expired (`days => -1`), so it is due on the
#     first run.
#
# Persistence to disk:
#   - HAProxy 3.2 does NOT auto-write issued certs (verified against
#     src/acme.c at v3.2.0 — only the account key is persisted; per-domain
#     certs live in memory and are announced via the dpapi sink).
#   - haproxy-dump-certs.timer (defined below) fires every 30 minutes and
#     pulls any in-memory cert that differs from disk via the admin socket.
#     It covers certs the renew run did not dump itself.
#
# Directory split:
#   $_acme_dir (/etc/ssl/private/acme) — .crt + .key (puppet-managed, never
#     overwritten after first creation due to force => false on the cert).
#   $_pem_dir  (/etc/haproxy/certs)    — .pem (loaded by haproxy, rewritten
#     in place by haproxy-dump-certs.sh once LE issues real certs).
#
# @param domains
#   The eit_haproxy domains hash (group => { force_https, domains, ... }).
#
# @param renew_days
#   Renew a certificate once it has fewer than this many days left. It has to
#   start before the 7-day expiry alert and stay well under the certificate
#   lifetime, or every run would renew everything.
class eit_haproxy::native_acme (
  Eit_haproxy::Domains $domains    = {},
  Integer[8,30]        $renew_days = 30,
) {
  $_acme_dir      = '/etc/ssl/private/acme'
  $_pem_dir       = '/etc/haproxy/certs'
  $_crt_list_path = '/etc/haproxy/crt-list.txt'
  $_public_ips    = lookup('common::system::publicips', Array, undef, [])

  # Generate certs and crt-list entries for ALL domain groups, regardless of
  # force_https. force_https controls only the HTTP->HTTPS redirect (handled
  # in basic_config.pp); cert loading is independent. Domains with
  # force_https=false still need certs because HSTS-cached browsers will
  # force HTTPS and strict-sni would otherwise reject the handshake.
  $_managed_groups = $domains

  # Source material — puppet generates .crt + .key here. force => false on
  # the openssl resource means these are never regenerated once present, so
  # the directory contents are stable across puppet runs.
  file { $_acme_dir:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    require => File['/etc/ssl/private'],
  }

  # Runtime cert dir — HAProxy loads .pem files from here, and
  # haproxy-dump-certs.sh writes real LE certs back to the same paths after
  # issuance. NOTE: purge/recurse intentionally omitted — purging would nuke
  # dumped LE certs between issuance and the next puppet run.
  file { $_pem_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  $_managed_groups.each |$group_name, $opts| {
    $_safe = regsubst($group_name, /[^a-zA-Z0-9.-]/, '_', 'G')

    # Self-signed placeholder cert + key. Born expired (days => -1) so
    # haproxy-acme-renew.sh treats it as due on its first run.
    #
    # NOTE on days => -1: this works because the provider's CSR branch shells
    # out to `openssl x509 -req -days <n> ...` which accepts negative values.
    # The other branch (`openssl req -new -x509 -days <n> ...`, taken when no
    # CSR is supplied) rejects non-positive days. Our wrapper always supplies
    # a CSR, so we hit the accepting path.
    openssl::certificate::x509 { $_safe:
      ensure     => present,
      commonname => $opts['domains'][0],
      altnames   => $opts['domains'],
      days       => -1,
      base_dir   => $_acme_dir,
      key_size   => 4096,
      encrypted  => false,
      force      => false,
      owner      => 'root',
      group      => 'root',
      require    => File[$_acme_dir],
    }

    # Concatenate <safe>.crt + <safe>.key into the .pem HAProxy expects.
    # `creates` makes this idempotent — once the .pem exists (placeholder OR
    # a real LE cert dumped back by haproxy-dump-certs.sh), the cat is
    # skipped and the existing .pem is preserved.
    exec { "haproxy-acme-assemble-${_safe}":
      command => "/bin/cat ${_acme_dir}/${_safe}.crt ${_acme_dir}/${_safe}.key > ${_pem_dir}/${_safe}.pem && /bin/chmod 600 ${_pem_dir}/${_safe}.pem",
      creates => "${_pem_dir}/${_safe}.pem",
      require => [
        Openssl::Certificate::X509[$_safe],
        File[$_pem_dir],
      ],
      before  => File[$_crt_list_path],
    }
  }

  # Build the entries list once, render the whole crt-list from a template.
  $_entries = $_managed_groups.map |$group_name, $opts| {
    $_safe = regsubst($group_name, /[^a-zA-Z0-9.-]/, '_', 'G')
    $_sorted_map = sort_domains_on_tld($opts['domains'], $_public_ips, true)
    $_sorted = $_sorted_map.map |$cn, $san| {
      if $cn != 'rejected_domains' { $san }
    }.flatten.delete_undef_values.unique
    $_dom_array = $_sorted.empty ? {
      true  => $opts['domains'].sort.unique,
      false => $_sorted,
    }
    $_hash = {
      'pem'          => "${_pem_dir}/${_safe}.pem",
      'acme_domains' => $_dom_array.join(','),
      'sni_filters'  => $_dom_array.join(' '),
    }
    $_hash
  }

  file { $_crt_list_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => epp('eit_haproxy/crt-list.txt.epp', { 'entries' => $_entries }),
    notify  => Service['haproxy'],
  }

  # Persistence pipeline — see header comment for why this is needed.
  ensure_packages(['socat', 'openssl'])

  file { '/opt/obmondo/bin/haproxy-dump-certs.sh':
    ensure => file,
    source => 'puppet:///modules/eit_haproxy/haproxy-dump-certs.sh',
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  $_dump_timer = @(EOT)
    [Unit]
    Description=Dump HAProxy in-memory certificates to disk
    [Timer]
    OnCalendar=*:0/30
    RandomizedDelaySec=5m
    [Install]
    WantedBy=timers.target
    | EOT

  # No cert-name args → dump-certs.sh iterates every cert from
  # `show ssl cert` and de-dupes via SHA256 fingerprint (cmp_certkey).
  # No bash wrapper / socat / awk / xargs needed — the script handles it.
  $_dump_service = @(EOT)
    [Unit]
    Description=Dump HAProxy in-memory certificates to disk
    [Service]
    Type=oneshot
    ExecStart=/opt/obmondo/bin/haproxy-dump-certs.sh -s /var/run/haproxy.sock
    | EOT

  systemd::timer { 'haproxy-dump-certs.timer':
    ensure          => present,
    timer_content   => $_dump_timer,
    service_content => $_dump_service,
    active          => true,
    enable          => true,
    require         => [File['/opt/obmondo/bin/haproxy-dump-certs.sh'], Package['socat']],
  }

  # Renewal pipeline — see header comment.
  file { '/opt/obmondo/bin/haproxy-acme-renew.sh':
    ensure => file,
    source => 'puppet:///modules/eit_haproxy/haproxy-acme-renew.sh',
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  $_renew_timer = @(EOT)
    [Unit]
    Description=Renew HAProxy ACME certificates that are due
    [Timer]
    OnCalendar=*-*-* 00/12:00:00
    RandomizedDelaySec=30m
    [Install]
    WantedBy=timers.target
    | EOT

  $_renew_service = @("EOT")
    [Unit]
    Description=Renew HAProxy ACME certificates that are due
    After=haproxy.service
    [Service]
    Type=oneshot
    ExecStart=/opt/obmondo/bin/haproxy-acme-renew.sh ${renew_days}
    | EOT

  systemd::timer { 'haproxy-acme-renew.timer':
    ensure          => present,
    timer_content   => $_renew_timer,
    service_content => $_renew_service,
    active          => true,
    enable          => true,
    require         => [
      File['/opt/obmondo/bin/haproxy-acme-renew.sh'],
      File['/opt/obmondo/bin/haproxy-dump-certs.sh'],
      Package['socat'],
    ],
  }

  # Run the renew job on every haproxy start.
  $_renew_dropin = @(EOT)
    [Unit]
    Wants=haproxy-acme-renew.service
    | EOT

  systemd::dropin_file { 'acme-renew.conf':
    unit           => 'haproxy.service',
    content        => $_renew_dropin,
    notify_service => false,
  }
}
