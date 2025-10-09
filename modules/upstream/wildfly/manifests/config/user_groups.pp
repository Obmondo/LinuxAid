#
# Manages groups for a Management User (`mgmt-groups.properties`).
#
# @param groups List of groups to associate with this user.
define wildfly::config::user_groups(String $groups) {

  file_line { "${title}:${groups}":
    path   => "${wildfly::dirname}/${wildfly::mode}/configuration/mgmt-groups.properties",
    line   => "${title}=${groups}",
    match  => "^${title}=.*\$",
    notify => Service['wildfly'],
  }

}
