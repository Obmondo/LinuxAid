# @summary HAProxy 3.x native ACME — placeholder certs and crt-list assembly.
#
# For each managed domain group with force_https=true:
#   1. Generates a self-signed placeholder cert via openssl::certificate::x509
#      at $_acme_dir/<sanitised>.{crt,key} (puppet-managed source material).
#   2. An exec concatenates cert+key into $_pem_dir/<sanitised>.pem (HAProxy's
#      expected format). `creates =>` makes it idempotent — the .pem is never
#      rebuilt once it exists, which protects real LE certs that
#      haproxy-dump-certs.sh later writes back to the same path.
#   3. The crt-list is rendered as a single file from an EPP template,
#      binding each PEM to the `acme LE` section. Notifying haproxy reload
#      causes haproxy's native ACME scheduler to fire on the new worker's
#      config postparse — see below.
#
# How issuance happens (no custom bootstrap script needed):
#   - HAProxy 3.2 has a native ACME scheduler that's enabled by default
#     (`global_ssl.acme_scheduler = 1`) and registered as a config
#     postparser (REGISTER_CONFIG_POSTPARSER). Every config parse — initial
#     start AND every reload — wakes the scheduler task immediately
#     (task_wakeup with TASK_WOKEN_INIT, see src/acme.c:577-587 at v3.2.0).
#   - The scheduler walks every cert in the crt-list, calls
#     acme_will_expire() (renewal window = validity / 12), and for our
#     `days => -1` placeholder this is trivially true (notAfter is in the
#     past, so any future-time check passes). Renewal is kicked off
#     immediately via acme_start_task().
#   - LE responds in ~5-30s, scheduler swaps the real cert into memory at
#     the same crt-list slot.
#   - After that, the scheduler re-runs every 12h (acme.c:2147).
#
# Persistence to disk:
#   - On every haproxy reload, the ExecReload dropin in init.pp runs
#     haproxy-dump-certs.sh (reads `show ssl cert` from the admin socket
#     and writes any in-memory cert that differs from disk).
#   - haproxy-dump-certs.timer fires daily at 03:00 as a backstop.
#
# Known race: ExecReload runs synchronously during the reload, before the
# scheduler has had time to complete LE issuance. So the *first* reload
# after a placeholder is added dumps before LE has responded — the cert
# lives in memory only until the next reload (any subsequent puppet config
# change) or the daily timer. Worst case: ~24h gap. If haproxy restarts in
# that window, the placeholder is reloaded, scheduler re-issues from LE
# (uses some LE rate-limit budget), and persistence is retried.
#
# Directory split:
#   $_acme_dir (/etc/ssl/private/acme) — .crt + .key (puppet-managed, never
#     overwritten after first creation due to force => false on the cert).
#   $_pem_dir  (/etc/haproxy/certs)    — .pem (loaded by haproxy, rewritten
#     in place by haproxy-dump-certs.sh once LE issues real certs).
#
# @param domains
#   The eit_haproxy domains hash (group => { force_https, domains, ... }).
class eit_haproxy::native_acme (
  Eit_haproxy::Domains $domains = {},
) {
  $_acme_dir      = '/etc/ssl/private/acme'
  $_pem_dir       = '/etc/haproxy/certs'
  $_crt_list_path = '/etc/haproxy/crt-list.txt'
  $_public_ips    = lookup('common::system::publicips', Array, undef, [])

  $_managed_groups = $domains.filter |$_group_name, $opts| {
    $opts['force_https']
  }

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
    # haproxy's ACME scheduler treats it as renewal-pending on the first
    # config postparse and triggers LE issuance immediately.
    #
    # NOTE on days => -1: this works because the provider's CSR branch shells
    # out to `openssl x509 -req -days <n> ...` which accepts negative values.
    # The other branch (`openssl req -new -x509 -days <n> ...`, taken when no
    # CSR is supplied) rejects non-positive days. Our wrapper always supplies
    # a CSR, so we hit the accepting path.
    openssl::certificate::x509 { $_safe:
      ensure     => present,
      commonname => $group_name,
      altnames   => [$group_name],
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
    $_sorted_map = sort_domains_on_tld($opts['domains'], $_public_ips)
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
}
