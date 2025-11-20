# EnableIT Client
class eit_repos::yum::centos_base (
  Boolean               $ensure     = true,
  Eit_types::Noop_Value $noop_value = $eit_repos::noop_value,
) {

  package::install('centos-release')

  ['base','extras','updates'].each | $repo | {
    $_repo = if $repo == 'base' {
      'os'
    } else {
      $repo
    }

    $_os = $facts['os']
    $_repo_parameters = "${_os['name']}-${_os['release']['major']}" ? {
      'CentOS-6' => {
        baseurl => "http://vault.centos.org/${_os['release']['full']}/${_repo}/\$basearch/",
      },
      default => {
        mirrorlist => "http://mirrorlist.centos.org/?release=\$releasever&arch=\$basearch&repo=${_repo}",
      },
    }

    yumrepo { $repo :
      ensure   => ensure_present($ensure),
      noop     => $noop_value,
      enabled  => 1,
      gpgcheck => 1,
      gpgkey   => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-${_os['release']['major']}",
      descr    => "CentOS-\$releasever - ${repo.capitalize}",
      require  => Package['centos-release'],
      *        => $_repo_parameters,
    }
  }
}
