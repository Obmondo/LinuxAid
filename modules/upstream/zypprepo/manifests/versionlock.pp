# @summary Locks package from updates.
#
# @example Sample usage
#   zypprepo::versionlock { 'bash-4.1.2-9.sles12.*': }
#
# @param ensure
#   Specifies if versionlock should be `present` or `absent`.
#
# @note The resource title must use the format
#   "%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}".  This can be retrieved via
#   the command `rpm -q --qf '%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}'.
#   Wildcards may be used within token slots, but must not cover seperators,
#   e.g., 'b*sh-4.1.2-9.*' covers Bash version 4.1.2, revision 9 on all
#   architectures.
#
define zypprepo::versionlock {
  require zypprepo::plugin::versionlock

  assert_type(Zypprepo::VersionlockString, $name) |$_expected, $actual | {
    fail("Package name must be formatted as %{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}, not \'${actual}\'. See Zypprepo::Versionlock documentation for details.")
  }

  concat::fragment { "zypprepo-versionlock-${name}":
    content => "\ntype: package\n\
match_type: glob\n\
case_sensitive: on\n\
solvable_name: ${name}\n",
    target  => $zypprepo::plugin::versionlock::path,
  }
}
