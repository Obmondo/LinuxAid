# == Define: mit_krb5::realm
#
# Add a Kerberos realm to krb5.conf
#
# === Parameters
#
# [*kdc*]
#   The value of this relation is the name of a host running a KDC for that
#   realm.  An optional port number (preceded by a colon) may be appended to
#   the hostname.  This tag should generally be used only if the realm
#   administrator has not made the information available through DNS.
#
# [*kpasswd_server*]
#    Points to the server where all the password changes are performed. If
#    there is no such entry, the port 464 on the admin_server host will be
#    tried.
#
# [*master_kdc*]
#   Identifies the master KDC(s). Currently, this tag is used in only one case:
#   If an attempt to get credentials fails because of an invalid password, the
#   client software will attempt to contact the master KDC, in case the user’s
#   password has just been changed, and the updated database has not been
#   propagated to the slave servers yet.
#
# [*admin_server*]
#   This relation identifies the host where the administration server is
#   running.  Typically this is the Master Kerberos server.
#
# [*database_module*]
#   This relation indicates the name of the configuration section under
#   dbmodules for database specific parameters used by the loadable database
#   library.
#
# [*default_domain*]
#   This relation identifies the default domain for which hosts in this realm
#   are assumed to be in.  This is needed for translating V4 principal names
#   (which do not contain a domain name) to V5 principal names (which do).
#
# [*v4_instance_convert*]
#   This subsection allows the administrator to configure exceptions to the
#   default_domain mapping rule.  It contains V4 instances (the tag name) which
#   should be translated to some specific hostname (the tag value) as the
#   second component in a Kerberos V5 principal name.
#
# [*v4_realm*]
#   This relation is used by the krb524 library routines when converting a V5
#   principal name to a V4 principal name.  It is used when V4 realm name and
#   the V5 realm are not the same, but still share the same principal names and
#   passwords. The tag value is the Kerberos V4 realm name.
#
# [*v4_realm_convert*]
#   Add a v4 realm convert, v4_name_convert, takes the following format => 
#   v4_realm_convert => { host=> [ "TEST = host", "TEST1 = host], TEST2 => ["TEST4=host2"]} , to produce :
#         v4_name_convert = {
#            host = {
#                TEST = host
#		 TEST1 = host
#            }
#	     TEST2 = {
#		 TEST4 = host2
#	     }
#        }
#                                                   
# [*auth_to_local_names*]
#   This subsection allows you to set explicit mappings from principal names to
#   local user names.  The tag is the mapping name, and the value is the
#   corresponding local user name.
#
# [*auth_to_local*]
#   This tag allows you to set a general rule for mapping principal names to
#   local user names.  It will be used if there is not an explicit mapping for
#   the principal name that is being translated.  The possible values are:
#
#   DB:<filename>
#       The principal will be looked up in the database <filename>.  Support
#       for this is not currently compiled in by default.
#   RULE:<exp>
#       The local name will be formulated from <exp>.
#   DEFAULT
#       The principal name will be used as the local name.  If the principal
#       has more than one component or is not in the default realm, this rule
#       is not applicable and the conversion will fail.
#
# [*pkinit_anchors*]
#   This relation allows you set the path of a certificate authority file.
#
# [*pkinit_pool*]
#   Specifies the location of intermediate certificates which may be used by the
#   client to complete the trust chain between a KDC certificate and a trusted anchor.
#
# [*http_anchors*]
#   When  KDCs and kpasswd servers are accessed through HTTPS proxies, this tag can
#   be used to specify the location of the CA certificate which should be trusted to
#   issue the certificate for a proxy server.
#
# [*rotate_servers*]
#   Whether to apply a random rotation to the list of KDCs and admin servers so
#   that the server usage is more evenly distributed.  (Default: `false`)
#
# === Examples
#
#  mit_krb5::realm { 'TEST.COM':
#    kdc            => [ 'kdc1.test.com', 'kdc2.test.com' ],
#    kpasswd_server => 'kpasswd.test.com',
#  }
#
# === Authors
#
# Patrick Mooney <patrick.f.mooney@gmail.com>
# Hristo Mohamed <hristo.mohamed@gmail.com>
# Remi Ferrand <remi.ferrand_at_cc.in2p3.fr>
#
# === Copyright
#
# Copyright 2013 Patrick Mooney.
# Copyright (c) IN2P3 Computing Centre, IN2P3, CNRS
#
define mit_krb5::realm(
  $kdc                    = '',
  $master_kdc             = '',
  $admin_server           = '',
  $database_module        = '',
  $default_domain         = '',
  $v4_instance_convert    = '',
  $v4_realm               = '',
  $auth_to_local_names    = '',
  $auth_to_local          = '',
  $kpasswd_server         = '',
  $v4_realm_convert       = '',
  $pkinit_anchors         = '',
  $pkinit_pool            = '',
  Boolean $rotate_servers = false,
  $http_anchors           = '',
) {

  include ::mit_krb5

  ensure_resource('concat::fragment', 'mit_krb5::realm_header', {
    target  => $mit_krb5::krb5_conf_path,
    order   => '10realm_header',
    content => "[realms]\n",
  })
  concat::fragment { "mit_krb5::realm::${title}":
    target  => $mit_krb5::krb5_conf_path,
    order   => "11realm_${title}",
    content => template('mit_krb5/realm.erb'),
  }
}
