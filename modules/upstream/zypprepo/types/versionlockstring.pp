# This type matches strings appropriate for use with zypprepo-versionlock.
# Its basic format, using the `rpm(8)` query string format, is
# `%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}`.  As a Regex, it
# breaks down into five distinct parts, plus the seperators.
#
#   # NAME: Any valid package name (see https://github.com/rpm-software-management/rpm/blob/master/doc/manual/spec)
#   type Zypprepo::PackageName    = Regexp[/[0-9a-zA-Z\._\+%\{\}\*-]+/]
#
#   # VERSION: Any valid version string. The only limitation here, according to the RPM manual, is that it may not contain a dash (`-`).
#   type Zypprepo::PackageVersion = Regexp[/[^-]+/]
#
#   # RELEASE: Any valid release string. Only limitation is that it is not a dash (`-`)
#   type Zypprepo::PackageRelease = Regexp[/[^-]+/]
#
#   # ARCH: Matches a string such as `sles12.x86_64`.  This is actuall two sub-expressions.  See below.
#   type Zypprepo::PackageArch    = Regexp[/([0-9a-zZ-Z_\*]+)(?:\.(noarch|x86_64|i386|arm|ppc64|ppc64le|sparc64|ia64|alpha|ip|m68k|mips|mipsel|mk68k|mint|ppc|rs6000|s390|s390x|sh|sparc|xtensa|\*))?/]
#
# The `%{ARCH}` sub-expression is composed of two sub-expressions
# separated by a dot (`.`), where the second part is optional.  The RPM
# specification calls the first field the `DistTag`, and the second the
# `BuildArch`.
#
#    # DistTag: Any string consiting of only letters, numbers, or an underscore, e.g., `sles12` or `suse15`.
#    type Zypprepo::PackageDistTag   = Regexp[/[0-9a-zZ-Z_\*]+/]
#
#    # BuildArch: Any string from the list at https://github.com/rpm-software-management/rpm/blob/master/rpmrc.in.  Strings are roughly listed from most common to least common to improve performance.
#    type Zypprepo::PackageBuildArch = Regexp[/noarch|x86_64|i386|arm|ppc64|ppc64le|sparc64|ia64|alpha|ip|m68k|mips|mipsel|mk68k|mint|ppc|rs6000|s390|s390x|sh|sparc|xtensa/]
#
# @note Each field may contain wildcard characters (`*`), but the
# wildcard characters may not span the fields, may not cover the
# seperators.  This is an undocumented but tested limitation of
# yum-versionlock.
#
# @example A complete, well-formed string: `ash-4.1.2-9.sles12_2.x86_64'
# @example A well-formed string that has dropped the optional BuildArch sub-field: `bash-4.1.2-9.suse15`
# @example A well-formed string using wildcards: `*0:bash*-4.*-*.*`
# @example An invalid string (wildcard spans the VERSION and RELEASE fields): `0:bash-4.*-sles12.x86_64
# @example An invlaid string (wildcard spans the VERSION, RELEASE, and ARCH fields): `0:bash-*`
#
type Zypprepo::VersionlockString = Pattern[/^([0-9a-zA-Z\._\+%\{\}\*-]+)-([^-]+)-([^-]+)\.(([0-9a-zZ-Z_\*]+)(?:\.(noarch|x86_64|i386|arm|ppc64|ppc64le|sparc64|ia64|alpha|ip|m68k|mips|mipsel|mk68k|mint|ppc|rs6000|s390|s390x|sh|sparc|xtensa|\*))?)$/]
