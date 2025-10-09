#
# Manages roles for an Application User (`application-roles.properties`).
#
# @param groups List of roles to associate with this user.
define wildfly::config::user_roles(String $roles) {

  file_line { "${title}:${roles}":
    path   => "${wildfly::dirname}/${wildfly::mode}/configuration/application-roles.properties",
    line   => "${title}=${roles}",
    match  => "^${title}=.*\$",
    notify => Service['wildfly'],
  }

}
