#
# Associate groups to user
#
define wildfly::config::user_groups($groups) {

  file_line { "${name}:${groups}":
    path  => "${wildfly::dirname}/${wildfly::mode}/configuration/mgmt-groups.properties",
    line  => "${name}=${groups}",
    match => "^${name}=.*\$"
  }

}