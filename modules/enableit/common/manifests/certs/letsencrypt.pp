# @summary Class for managing Let's Encrypt certificates
#
# @param email The email address associated with the certificates. Defaults to 'ops@obmondo.com'.
#
# @param ca The Certificate Authority environment. Defaults to 'production'. Allowed values are 'production' and 'staging'.
#
# @param renew Whether to automatically renew certificates. Defaults to true.
#
# @param http_01_port The port used for HTTP-01 challenge. Defaults to 63480.
#
# @param challenges The challenge type for certificate issuance. Defaults to 'http'. Allowed values are 'http', 'dns', etc.
#
# @param domains List of domain names for the certificates.
#
# @param warning Warning threshold for renewal. Defaults to 7 days.
#
# @param critical Critical threshold for renewal. Defaults to 4 days.
#
# @param cert_host Optional certificate host override.
#
# @param deploy_hook_command Optional command to run after deployment.
#
# @param distribute_to List of hosts or locations to distribute the certificates to.
#
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
