# Dell yum repos
class eit_repos::yum::dell (
  Boolean               $ensure     = false,
  Eit_types::Noop_Value $noop_value = undef,

  String                $repo_baseurl    = lookup('eit_repos::dell::repo_baseurl'),
  String                $gpg_key_baseurl = lookup('eit_repos::dell::gpg_key_baseurl'),
  Array[String]         $gpg_key_ids     = lookup('eit_repos::dell::gpg_key_ids'),
) inherits eit_repos::yum {

  $gpg_key_ids.each |$key_id| {
    eit_repos::yum::gpgkey { "dell-system-update-${key_id}" :
      ensure     => ensure_present($ensure),
      path       => "/etc/pki/rpm-gpg/RPM-GPG-KEY-dell-system-update-${key_id}",
      source     => "${gpg_key_baseurl}${key_id}.asc",
      noop_value => $noop_value,
    }
  }

  $gpgkey_urls = $gpg_key_ids.map |$key_id| { "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-dell-system-update-${key_id}" }.join(' ')

  $repos = {
    'dell-system-update_dependent' => "${repo_baseurl}mirrors.cgi?osname=el\$releasever&basearch=\$basearch&native=1",
    'dell-system-update_independent' => "${repo_baseurl}os_independent/",
  }

  $repos.each | $key, $value | {
    yumrepo { $key :
      ensure     => ensure_present($ensure),
      mirrorlist => $value,
      enabled    => 1,
      noop       => $noop_value,
      gpgcheck   => 1,
      gpgkey     => $gpgkey_urls,
      descr      => $key,
    }
  }
}
