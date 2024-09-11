#
# add wildlfy user
#
define wildfly::config::user($username, $password, $file_name, $realm) {

  $password_hash = inline_template('<%= require \'digest/md5\'; Digest::MD5.hexdigest("#{@username}:#{@realm}:#{@password}") %>')

  file_line { "${username}:${realm}":
    path  => "${wildfly::dirname}/${wildfly::mode}/configuration/${file_name}",
    line  => "${username}=${password_hash}",
    match => "^${username}=.*\$"
  }
}