# CA Cert
define profile::certs::ca_cert (
  Eit_types::Cert::Ensure $ensure,
  Customers::Source       $source,

  Optional[Eit_types::Cert::Update] $update = undef,
) {

  $_file = customers::to_file($source)

  trusted_ca::ca { $name:
    source => $_file['resource']['source'],
  }
}
