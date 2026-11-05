# @summary Ubuntu -proposed pocket, for a fix that is not in -updates yet
#
# Plain files rather than apt::source and apt::pin, so it also works on nodes where the
# apt class is not managed (role::kubeaid).
#
# @param enable Add the <codename>-proposed source. Ubuntu marks the pocket NotAutomatic,
#   so apt installs nothing from it unless the package is listed in packages.
#
# @param packages Packages (apt globs allowed, e.g. 'linux-*') pinned to priority 500 in
#   -proposed, so a normal upgrade takes a newer version from there.
#
# @param noop_value Noop for the managed files.
#
class eit_repos::apt::proposed (
  Boolean               $enable     = false,
  Array[String[1]]      $packages   = [],
  Eit_types::Noop_Value $noop_value = undef,
) {
  if $facts['os']['distro']['id'] == 'Ubuntu' {
    $_codename = $facts['os']['distro']['codename']
    $_location = $facts['os']['architecture'] ? {
      /^(aarch64|arm64)$/ => 'http://ports.ubuntu.com/ubuntu-ports/',
      default             => 'http://archive.ubuntu.com/ubuntu/',
    }

    File {
      owner => 'root',
      group => 'root',
      mode  => '0644',
      noop  => $noop_value,
    }

    file { '/etc/apt/sources.list.d/ubuntu-proposed.sources':
      ensure  => stdlib::ensure($enable, 'file'),
      content => @("EOT"),
        # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
        Types: deb
        URIs: ${_location}
        Suites: ${_codename}-proposed
        Components: main universe multiverse restricted
        Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
        | EOT
    }

    file { '/etc/apt/preferences.d/ubuntu-proposed.pref':
      ensure  => stdlib::ensure($enable and !$packages.empty, 'file'),
      content => @("EOT"),
        # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
        Package: ${packages.join(' ')}
        Pin: release a=${_codename}-proposed
        Pin-Priority: 500
        | EOT
    }
  }
}
