# Docker sles repos
class eit_repos::zypper::dell (
  Boolean               $ensure     = true,
  Eit_types::Noop_Value $noop_value = undef,

  String                $repo_baseurl    = lookup('eit_repos::dell::repo_baseurl'),
  String                $gpg_key_baseurl = lookup('eit_repos::dell::gpg_key_baseurl'),
  Array[String]         $gpg_key_ids     = lookup('eit_repos::dell::gpg_key_ids'),
) inherits eit_repos::zypper {

  $distro = "sles${facts['os']['release']['major']}"

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
    'dell-system-update_dependent' => "${repo_baseurl}mirrors.cgi/osname=${distro}&basearch=\$basearch&native=1&redirpath=/",
    'dell-system-update_independent' => "${repo_baseurl}os_independent/",
  }

  $repos.each | $key, $value | {
    zypprepo { $key:
      ensure      => ensure_present($ensure),
      baseurl     => $value,
      enabled     => 1,
      autorefresh => 1,
      gpgcheck    => 1,
      gpgkey      => $gpgkey_urls,
      noop        => $noop_value,
    }
  }
}
