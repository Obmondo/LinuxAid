# Generic Wildfly user management.
#
# @param password User password.
# @param file_name Name of config file.
#
define wildfly::config::user (
  String $password,
  String $file_name,
) {
  $user_info = split($title, ':')
  $username = $user_info[0]
  $realm = $user_info[1]

  $password_hash = inline_template('<%= require \'digest/md5\'; Digest::MD5.hexdigest("#{@username}:#{@realm}:#{@password}") %>')

  require wildfly::install

  file_line { "${username}:${realm}":
    path   => "${wildfly::dirname}/${wildfly::mode}/configuration/${file_name}",
    line   => "${username}=${password_hash}",
    match  => "^${username}=.*\$",
    notify => Service['wildfly'],
  }
}
