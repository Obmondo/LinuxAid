# CA Cert
define profile::certs::ca_cert (
  Eit_types::Cert::Ensure $ensure,
  Eit_Files::Source       $source,

  Optional[Eit_types::Cert::Update] $update = undef,
) {

  $_file = eit_files::to_file($source)

  trusted_ca::ca { $name:
    source => $_file['resource']['source'],
  }
}
