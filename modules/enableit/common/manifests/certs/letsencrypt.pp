# Let's Encrypt certificates
class common::certs::letsencrypt (
  Eit_types::Email                                        $email               = 'ops@obmondo.com',
  Enum[
    'production',
    'staging'
  ]                                                       $ca                  = 'production',
  Boolean                                                 $renew               = true,
  Stdlib::Port                                            $http_01_port        = 63480,
  Eit_types::Cert::Letsencrypt::Challenge                 $challenges          = 'http',
  Array[Stdlib::Fqdn]                                     $domains             = [],
  Optional[Integer]                                       $warning             = 7,
  Optional[Integer]                                       $critical            = 4,
  Optional[Variant[Eit_types::Certname, Eit_types::Host]] $cert_host           = undef,
  Optional[Variant[Stdlib::Absolutepath, String]]         $deploy_hook_command = undef,
  Array[Variant[Eit_types::Certname, Eit_types::Host]]    $distribute_to       = [],
) {

  $public_ips = lookup('common::settings::publicips', Array, undef, [])

  if $domains.size > 0 {
    sort_domains_on_tld($domains, $public_ips).each |$cn, $san| {
      profile::certs::letsencrypt::domain { $cn:
        domains => $san,
      }
    }
  }

}
