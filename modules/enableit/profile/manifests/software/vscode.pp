# Vscode
class profile::software::vscode (
  Boolean               $enable     = $common::software::vscode::enable,
  Eit_types::Noop_Value $noop_value = $common::software::vscode::noop_value,
){

  if $facts[os][family] == 'RedHat' {
    yumrepo { 'vscode':
      ensure        => ensure_present($enable),
      noop          => $noop_value,
      baseurl       => 'https://packages.microsoft.com/yumrepos/vscode',
      enabled       => 1,
      gpgcheck      => 1,
      repo_gpgcheck => 1,
      gpgkey        => 'https://packages.microsoft.com/keys/microsoft.asc',
      descr         => 'Visual Studio Code',
    }

    package { 'code':
      ensure => ensure_present($enable),
      noop   => $noop_value,
    }
  }
}
