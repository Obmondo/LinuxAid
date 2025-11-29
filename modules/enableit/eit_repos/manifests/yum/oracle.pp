# Oracle Linux YUM upstream repositories
class eit_repos::yum::oracle (
  Boolean               $ensure     = true,
  Eit_types::Noop_Value $noop_value = $eit_repos::noop_value,
) {

  $release = $facts['os']['release']['major']

  # Build repo map including BaseOS, AppStream and UEKR6
  $repo_map = {
    "ol${release}_baseos_latest" => "https://yum.oracle.com/repo/OracleLinux/OL${release}/baseos/latest/\$basearch/",
    "ol${release}_appstream"     => "https://yum.oracle.com/repo/OracleLinux/OL${release}/appstream/\$basearch/",
    "ol${release}_UEKR6"         => "https://yum.oracle.com/repo/OracleLinux/OL${release}/UEKR6/\$basearch/",
  }

  # Single yumrepo block used for all repos
  $repo_map.each |$repo_name, $repo_url| {
    yumrepo { $repo_name:
      ensure   => ensure_present($ensure),
      baseurl  => $repo_url,
      enabled  => 1,
      gpgcheck => 1,
      descr    => "Oracle Linux ${release} repository ${repo_name} (\$basearch)",
      gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle',
      noop     => $noop_value,
    }
  }

  # Oracle GPG key
  eit_repos::yum::gpgkey { 'oracle':
    ensure     => ensure_present($ensure),
    path       => '/etc/pki/rpm-gpg/RPM-GPG-KEY-oracle',
    source     => 'puppet:///modules/eit_repos/yum/RPM-GPG-KEY-oracle',
    noop_value => $noop_value,
  }
}
