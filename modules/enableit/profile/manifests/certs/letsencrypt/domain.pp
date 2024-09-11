# Certificates
# NOTE: only haproxy role support letsencrypt for now
# blackbox will scrape the domains if its given in the role::web::haproxy
define profile::certs::letsencrypt::domain (
  Eit_types::Email                                               $email               = $::common::certs::letsencrypt::email,
  Enum[
    'production',
    'staging'
  ]                                                              $ca                  = $::common::certs::letsencrypt::ca,
  Boolean                                                        $renew               = $::common::certs::letsencrypt::renew,
  Array[Stdlib::Fqdn]                                            $domains             = $::common::certs::letsencrypt::domains,
  Stdlib::Port                                                   $http_01_port        = $::common::certs::letsencrypt::http_01_port, # lint:ignore:140chars
  Eit_types::Cert::Letsencrypt::Challenge                        $challenges          = $::common::certs::letsencrypt::challenges,
  Optional[Integer]                                              $warning             = $::common::certs::letsencrypt::warning,
  Optional[Integer]                                              $critical            = $::common::certs::letsencrypt::critical,
  Optional[Variant[Eit_types::Certname, Eit_types::Host]]        $cert_host           = $::common::certs::letsencrypt::cert_host,
  Optional[Variant[Stdlib::Absolutepath, String]]                $deploy_hook_command = $::common::certs::letsencrypt::deploy_hook_command, # lint:ignore:140chars
  Optional[Array[Variant[Eit_types::Certname, Eit_types::Host]]] $distribute_to       = $::common::certs::letsencrypt::distribute_to, # lint:ignore:140chars
) {

  include ::profile::certs::letsencrypt

  # The rejected_domains comes from the function sort_domains_on_tld
  if $name == 'rejected_domains' {
    if $domains.size > 0 {
      notify { "These domains got rejected because its not pointing to correct server = ${domains}": }
      file {'/etc/puppetlabs/facter/facts.d/obmondo_certs_rejected.json':
        ensure  => present,
        mode    => '0644',
        content => to_json({
          'rejected_domains' => $domains
        }),
        noop    => false,
      }
    }
  } else {
    letsencrypt::certonly { $name:
      domains              => $domains,
      cert_name            => $name,
      plugin               => 'standalone',
      manage_cron          => false,
      deploy_hook_commands => $deploy_hook_command,
      additional_args      => [
        "--preferred-challenges ${challenges}",
        "--http-01-port ${http_01_port}",
      ],
    }

    # Handle a situation where there was never an instance where the domians were rejected due to any reason
    # and hence the facter file is not ever written, so take care by giving an empty array
    $rejected_domains = pick($facts.dig('rejected_domains'), [])

    # Monitor the CN, since SAN are part of same cert, so expiry would be same ofcourse :)
    monitor::domains::expiry { $name:
      enable => true,
    }

    # Setup ENV file for each domain
    if size($distribute_to) > 0 {
      $tld_domain = get_domain_tld($name)

      file { "${tld_domain} and ${name}" :
        ensure  => present,
        path    => "/etc/obmondo/certs/domains/${tld_domain}",
        content => epp('profile/letsencrypt-post-hook.bash.epp', {
          domain          => $name,
          tld_domain      => $tld_domain,
          remote_hosts    => $distribute_to,
          rsync_options   => '--copy-links --archive --compress --perms --times',
          ssh_pubkey      => '/root/.ssh/id_rsa',
          ssh_local_user  => 'root',
          ssh_remote_user => 'root'
        }),
        require => File['/etc/obmondo/certs/domains'],
      }
    }
  }
}
