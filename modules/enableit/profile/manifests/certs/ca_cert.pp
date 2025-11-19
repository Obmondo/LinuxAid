# CA Cert
define profile::certs::ca_cert (
  Optional[Eit_Files::Source]       $source  = undef,
  Optional[String]                  $content = undef,
  Optional[Eit_types::Cert::Update] $update  = undef,
) {

  $_file = $source ? {
    Eit_Files::Source => eit_files::to_file($source),
    default           => undef,
  }

  trusted_ca::ca { $name:
    source  => dig($_file, 'resource', 'source'),
    content => $content,
  }
}
