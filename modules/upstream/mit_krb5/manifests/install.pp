# == Class: mit_krb5::install
#
# Install MIT Kerberos v5 client.
#
# === Authors
#
# Patrick Mooney <patrick.f.mooney@gmail.com>
#
# === Copyright
#
# Copyright 2013 Patrick Mooney.
# Copyright (c) IN2P3 Computing Centre, IN2P3, CNRS
#
class mit_krb5::install($packages = undef) {
  if $packages {
    if is_array($packages) {
      $install = flatten($packages)
    } else {
      $install = [$packages]
    }
  } else {
    # OS-specific defaults
    $install = $facts['os']['family'] ? {
      'Archlinux' => ['krb5'],
      'Debian'    => ['krb5-user'],
      'Gentoo'    => ['mit-krb5'],
      'Mandrake'  => ['krb5-workstation'],
      'RedHat'    => ['krb5-workstation'],
      'Suse'      => ['krb5-client'],
    }
  }
  ensure_packages($install)
}
