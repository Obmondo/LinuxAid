#
# Applies patches online. Requires server restart.
#
# @param source path to patch file.
# @param override_all Whether it should solve all conflicts by overriding current files.
# @param override List of files to be overridden.
# @param preserve List of files to be preserved.
define wildfly::patch::online (
  Stdlib::Unixpath $source,
  Boolean          $override_all = false,
  Array            $override     = [],
  Array            $preserve     = [],
) {
  $args = wildfly::patch_args($source, $override_all, $override, $preserve)

  exec { "Patch ${title}":
    command     => "jboss-cli.sh -c 'patch apply ${args}'",
    unless      => "jboss-cli.sh -c 'patch history' | grep -q ${title}",
    path        => ['/bin', '/usr/bin', '/sbin', "${wildfly::dirname}/bin"],
    environment => "JAVA_HOME=${wildfly::java_home}",
    require     => Service['wildfly'],
  }

  ~> wildfly::restart { "Restart for patch ${title}":
  }
}
