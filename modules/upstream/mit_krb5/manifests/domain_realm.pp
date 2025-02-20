# == Define: mit_krb5::domain_realm
#
# Add entries to the domain_realm section.
#
# === Parameters
#
# [*domains*]
#   Domains to map.
#
# [*realm*]
#   Realm to map domains into. (Default: $title)
#
# === Examples
#
#  mit_krb5::domain_realm { 'TEST.COM':
#    domains => [ 'other.com', '.other.com' ]
#  }
#
#  Results in:
#  [domain_realm]
#      other.com = TEST.COM
#      .other.com = TEST.COM
#
# === Authors
#
# Patrick Mooney <patrick.f.mooney@gmail.com>
# Remi Ferrand <remi.ferrand_at_cc.in2p3.fr>
#
# === Copyright
#
# Copyright 2013 Patrick Mooney.
# Copyright (c) IN2P3 Computing Centre, IN2P3, CNRS
#
define mit_krb5::domain_realm(
  Array[String] $domains,
  String $realm = $title,
) {
  include ::mit_krb5

  if count($domains) > 0 {
    ensure_resource('concat::fragment', 'mit_krb5::domain_realm_header', {
      target  => $mit_krb5::krb5_conf_path,
      order   => '20domain_realm_header',
      content => "[domain_realm]\n",
    })
    concat::fragment { "mit_krb5::domain_realm::${title}":
      target  => $mit_krb5::krb5_conf_path,
      order   => "21realm_${realm}_${title}",
      content => template('mit_krb5/domain_realm.erb'),
    }
    ensure_resource('concat::fragment', 'mit_krb5::domain_realm_trailer', {
      target  => $mit_krb5::krb5_conf_path,
      order   => '22domain_realm_trailer',
      content => "\n",
    })
  }
}
