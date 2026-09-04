# EnableIT Client
class eit_repos::yum::centos_base (
  Boolean               $ensure     = true,
  Eit_types::Noop_Value $noop_value = undef,
) {

  package::install('centos-release')

  ['base','extras','updates'].each | $repo | {
    $_repo = if $repo == 'base' {
      'os'
    } else {
      $repo
    }

    $_os = $facts['os']

    # CentOS 7 and older are EOL: mirrorlist.centos.org no longer resolves and
    # the packages only remain on the vault archive. Newer CentOS keeps the
    # mirrorlist.
    $_repo_parameters = ($_os['name'] == 'CentOS' and Integer($_os['release']['major']) < 8) ? {
      true    => {
        baseurl    => "http://vault.centos.org/${_os['release']['full']}/${_repo}/\$basearch/",
        mirrorlist => 'absent',
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
