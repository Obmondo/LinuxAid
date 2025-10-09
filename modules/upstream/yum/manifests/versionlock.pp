# @summary Locks package from updates.
#
# @example Sample usage on CentOS 7
#   yum::versionlock { '0:bash-4.1.2-9.el7.*':
#     ensure => present,
#   }
#
# @example Sample usage on CentOS 8
#   yum::versionlock { 'bash':
#     ensure => present,
#     version => '4.1.2',
#     release => '9.el8',
#     epoch   => 0,
#     arch    => 'noarch',
#   }
#
#
# @example Sample usage on CentOS 7 with new style version, release, epoch, name parameters.
#   yum::versionlock { 'bash':
#     ensure => present,
#     version => '3.1.2',
#     release => '9.el7',
#     epoch   => 0,
#     arch    => 'noarch',
#   }
#
# @param ensure
#   Specifies if versionlock should be `present`, `absent` or `exclude`.
#
# @param version
#   Version of the package if CentOS 8 mechanism is used. This must be set for dnf based systems (e.g CentOS 8).
#   If version is set then the name var is assumed to a package name and not the full versionlock string.
#
# @param release
#   Release of the package if CentOS 8 mechanism is used.
#
# @param arch
#   Arch of the package if CentOS 8 mechanism is used.
#
# @param epoch
#   Epoch of the package if CentOS 8 mechanism is used.
#
# @note The resource title must use the format
#   By default on CentOS 7 the following format is used.
#   "%{EPOCH}:%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}".  This can be retrieved via
#   the command `rpm -q --qf '%{EPOCH}:%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}'.
#   If "%{EPOCH}" returns as '(none)', it should be set to '0'.  Wildcards may
#   be used within token slots, but must not cover seperators, e.g.,
#   '0:b*sh-4.1.2-9.*' covers Bash version 4.1.2, revision 9 on all
#   architectures.
#   By default on CentOS 8 and newer the resource title  to just set the
#   package name.
#   If a version is set on CentOS 7 then it behaves like CentOS 8
#
# @see http://man7.org/linux/man-pages/man1/yum-versionlock.1.html
define yum::versionlock (
  Enum['present', 'absent', 'exclude']      $ensure  = 'present',
  Optional[Yum::RpmVersion]                 $version = undef,
  Yum::RpmRelease                           $release = '*',
  Integer[0]                                $epoch   = 0,
  Variant[Yum::RpmArch, Enum['*']]          $arch    = '*',
) {
  require yum::plugin::versionlock

  $line_prefix = $ensure ? {
    'exclude' => '!',
    default   => '',
  }

  if $facts['package_provider'] == 'yum' and $version =~ Undef {
    assert_type(Yum::VersionlockString, $name) |$_expected, $actual | {
      # lint:ignore:140chars
      fail("Package name must be formatted as %{EPOCH}:%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}, not \'${actual}\'. See Yum::Versionlock documentation for details.")
      # lint:endignore
    }

    $_versionlock = "${line_prefix}${name}"
  } else {
    assert_type(Yum::RpmNameGlob, $name) |$_expected, $actual | {
      fail("Package name must be formatted as Yum::RpmName, not \'${actual}\'. See Yum::Rpmname documentation for details.")
    }

    assert_type(Yum::RpmVersion, $version) |$_expected, $actual | {
      fail("Version must be formatted as Yum::RpmVersion, not \'${actual}\'. See Yum::RpmVersion documentation for details.")
    }

    $_versionlock = $facts['package_provider'] ? {
      'yum'   => "${line_prefix}${epoch}:${name}-${version}-${release}.${arch}",
      default => "${line_prefix}${name}-${epoch}:${version}-${release}.${arch}",
    }
  }

  unless $ensure == 'absent' {
    concat::fragment { "yum-versionlock-${name}":
      content => "${_versionlock}\n",
      target  => $yum::plugin::versionlock::path,
    }
  }
}
