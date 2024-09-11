#
# Associate roles to user
#

define wildfly::config::user_roles($roles) {

  file_line { "${name}:${roles}":
    path  => "${wildfly::dirname}/${wildfly::mode}/configuration/application-roles.properties",
    line  => "${name}=${roles}",
    match => "^${name}=.*\$"
  }

}