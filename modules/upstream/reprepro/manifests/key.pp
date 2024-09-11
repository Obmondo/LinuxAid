# == Definition: reprepro::key
#
# Import a PGP key into the local keyring of the reprepro user
#
# === Parameters
#
# - *key_source* Path to the key in gpg --export format. This is
#    used as the source parameter in a puppet File resource.
# - *homedir* Home directory of the reprepro user. Defaults to
#    /var/packages.
#
define reprepro::key (
  $key_source,
  $homedir    = $::reprepro::homedir,
) {

  include reprepro::params

  $keypath = "${homedir}/.gnupg/${name}"
  file {$keypath:
    ensure  => 'present',
    owner   => $::reprepro::user_name,
    group   => $::reprepro::group_name,
    mode    => '0660',
    source  => $key_source,
    require => User[$::reprepro::user_name],
    notify  => Exec["import-${name}"],
  }

  exec {"import-${name}":
    command     => "su -c 'gpg --import ${keypath}' ${::reprepro::user_name}",
    refreshonly => true,
  }
}
    
