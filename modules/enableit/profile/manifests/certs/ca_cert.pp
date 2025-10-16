# CA Cert
define profile::certs::ca_cert (
  Optional[Eit_Files::Source]       $source  = undef,
  Optional[String]                  $content = undef,
  Optional[Eit_types::Cert::Update] $update  = undef,
) {

  $_file = eit_files::to_file($source)

  trusted_ca::ca { $name:
    source  => $_file['resource']['source'],
    content => $_file['resource']['content'],
  }
}
