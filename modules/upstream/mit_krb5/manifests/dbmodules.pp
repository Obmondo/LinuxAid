# == Class: mit_krb5::dbmodules
#
# Configure dbmodules section of krb5.conf
#
# === Parameters
#
# [*realm*]
#   Realm this configuration applied to. Defaults to $title.
#
# [*database_name*]
#   This DB2-specific tag indicates the location of the database in the
#   filesystem. The default is LOCALSTATEDIR/krb5kdc/principal.
#
# [*db_library*]
#   This tag indicates the name of the loadable database module. The
#   value should be db2 for the DB2 module and kldap for the LDAP module.
#
# [*disable_last_success*]
#   If set to true, suppresses KDC updates to the “Last successful
#   authentication” field of principal entries requiring preauthentication.
#   Setting this flag may improve performance. (Principal entries which do not
#   require preauthentication never update the “Last successful authentication”
#   field.). First introduced in release 1.9.
#
# [*disable_lockout*]
#   If set to true, suppresses KDC updates to the “Last failed authentication”
#   and “Failed password attempts” fields of principal entries requiring
#   preauthentication. Setting this flag may improve performance, but also
#   disables account lockout. First introduced in release 1.9.
#
# [*ldap_cert_path*]
#   Path to the Network Security Services (NSS) trusted database for an SSL connection. 
#   This is a required parameter when using the LDAP KDB plug-in.
#
# [*ldap_conns_per_server*]
#   This LDAP-specific tag indicates the number of connections to be
#   maintained per LDAP server.
#
# [*ldap_kadmind_dn*]
#   This LDAP-specific tag indicates the default bind DN for the kadmind
#   daemon. kadmind does a login to the directory as this object. This object
#   should have the rights to read and write the Kerberos data in the LDAP
#   database.
#
# [*ldap_kdc_dn*]
#   This LDAP-specific tag indicates the default bind DN for the krb5kdc
#   daemon. The KDC does a login to the directory as this object. This object
#   should have the rights to read the Kerberos data in the LDAP database, and
#   to write data unless disable_lockout and disable_last_success are true.
#
# [*ldap_kerberos_container_dn*]
#   This LDAP-specific tag indicates the DN of the container object where the
#   realm objects will be located.
#
# [*ldap_servers*]
#   This LDAP-specific tag indicates the list of LDAP servers that the
#   Kerberos servers can connect to. The LDAP server is specified by a LDAP
#   URI. It is recommended to use ldapi: or ldaps: URLs to connect to the LDAP
#   server.
#
# [*ldap_service_password_file*]
#   This LDAP-specific tag indicates the file containing the stashed passwords
#   (created by kdb5_ldap_util stashsrvpw) for the ldap_kadmind_dn and
#   ldap_kdc_dn objects. This file must be kept secure.
#
# === Examples
#
#  mit_krb5::dbmodules { 'TEST.COM':
#    db_library => 'mylib.so'
#  }
#
#  Results in:
#  [dbmodules]
#      db_library = mylib.so
#
# === Authors
#
# Patrick Mooney <patrick.f.mooney@gmail.com>
# Modestas Vainius <modestas@vainius.eu>
#
# === Copyright
#
# Copyright 2013 Patrick Mooney.
# Copyright 2016 Modestas Vainius.
# Copyright (c) IN2P3 Computing Centre, IN2P3, CNRS
#
define mit_krb5::dbmodules(
  String $realm               = $title,
  $database_name              = '',
  $db_library                 = '',
  $disable_last_success       = '',
  $disable_lockout            = '',
  $ldap_cert_path             = '',
  $ldap_conns_per_server      = '',
  $ldap_kadmind_dn            = '',
  $ldap_kdc_dn                = '',
  $ldap_kerberos_container_dn = '',
  $ldap_servers               = '',
  $ldap_service_password_file = '',
) {
  include mit_krb5
  ensure_resource('concat::fragment', 'mit_krb5::dbmodules_header', {
    target  => $mit_krb5::krb5_conf_path,
    order   => '30dbmodules_header',
    content => "\n[dbmodules]\n",
  })
  if (! empty($mit_krb5::db_module_dir)) {
    ensure_resource('concat::fragment', 'mit_krb5::dbmodules_db_module_dir', {
      target  => $mit_krb5::krb5_conf_path,
      order   => '31dbmodules_db_module_dir',
      content => "    db_module_dir = ${mit_krb5::db_module_dir}\n",
    })
  }
  concat::fragment { "mit_krb5::dbmodules::${realm}":
    target  => $mit_krb5::krb5_conf_path,
    order   => "32dbmodules_${realm}",
    content => template('mit_krb5/dbmodules.erb'),
  }
}
