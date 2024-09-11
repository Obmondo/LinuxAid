#
# Import a PGP key into the local keyring of the reprepro user
#
# @param key_name
#   name of the key
# @param key_source
#   Path to the key in gpg --export format. This is
#   used as the source parameter in a puppet File resource.
# @param key_content
#   define the key content instead of pointing to a source file
#
define reprepro::key (
  String           $key_name    = $title,
  Optional[String] $key_source  = undef,
  Optional[String] $key_content = undef,
) {

  include reprepro

  $keypath = "${reprepro::homedir}/.gnupg/${key_name}"

  file {$keypath:
    ensure  => 'present',
    owner   => $::reprepro::user_name,
    group   => $::reprepro::group_name,
    mode    => '0660',
    source  => $key_source,
    content => $key_content,
    require => User[$::reprepro::user_name],
    notify  => Exec["import-${key_name}"],
  }

  exec {"import-${key_name}":
    path        => ['/usr/local/bin', '/usr/bin', '/bin'],
    command     => "su -c 'gpg --import ${keypath}' ${::reprepro::user_name}",
    refreshonly => true,
  }
}
