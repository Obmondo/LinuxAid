# == Class: mit_krb5::plugins
#
# Configure plugins section of krb5.conf
#
# === Possible subsections (resource titles)
#
# [*ccselect*]
#   The ccselect subsection controls modules for credential cache selection
#   within a cache collection.
#
# [*pwqual*]
#   The pwqual subsection controls modules for the password quality interface.
#
# [*kadm5_hook*]
#   The kadm5_hook interface provides plugins with information on
#   principal creation, modification, password changes and deletion.
#
# [*clpreauth*]
#   The clpreauth interface allows plugin modules to provide
#   client preauthentication mechanisms.
#
# [*kdcpreauth*]
#   The kdcpreauth interface allows plugin modules to provide
#   KDC preauthentication mechanisms.
#
# [*hostrealm*]
#   The hostrealm section controls modules for the host-to-realm interface,
#    which affects the local mapping of hostnames to realm names and
#    the choice of default realm.
#
# [*localauth*]
#   The localauth section controls modules for the local authorization
#   interface, which affects the relationship between Kerberos principals
#   and local system accounts.
#
# === Parameters
#
# [*disable*]
#   This tag may have multiple values. If there are values for this tag,
#   then the named modules will be disabled for the pluggable interface.
#
# [*enable_only*]
#   This tag may have multiple values. If there are values for this tag,
#   then only the named modules will be enabled for the pluggable interface.
#
# [*module*]
#   This tag may have multiple values. Each value is a string of the form
#   modulename:pathname, which causes the shared object located at pathname
#   to be registered as a dynamic module named modulename for the pluggable
#   interface. If pathname is not an absolute path, it will be treated as
#   relative to the plugin_base_dir value from [libdefaults].
#
# === Examples
#
#  mit_krb5::plugins { 'ccselect':
#    disable        => 'k5identity',
#  }
#
#  mit_krb5::plugins { 'pwqual':
#    enable_only    => [ 'dict', 'princ' ],
#  }
#
# === Authors
#
# Patrick Mooney <patrick.f.mooney@gmail.com>
# Oliver Freyermuth <freyermuth@physik.uni-bonn.de>
#
# === Copyright
#
# Copyright 2013 Patrick Mooney.
# Copyright (c) IN2P3 Computing Centre, IN2P3, CNRS
#
define mit_krb5::plugins(
  $disable     = undef,
  $enable_only = undef,
  $module      = undef,
) {

  include ::mit_krb5

  $interfaces = [
    'ccselect',
    'pwqual',
    'kadm5_hook',
    'clpreauth',
    'kdcpreauth',
    'hostrealm',
    'localauth',
  ]
  unless $title in $interfaces {
    fail("Interface ${title} not supported in plugins section!")
  }

  ensure_resource('concat::fragment', 'mit_krb5::plugins_header', {
    target  => $mit_krb5::krb5_conf_path,
    order   => '40plugins_header',
    content => "[plugins]\n",
  })
  concat::fragment { "mit_krb5::plugins::${title}":
    target  => $mit_krb5::krb5_conf_path,
    order   => "41plugins_${title}",
    content => template('mit_krb5/plugins.erb'),
  }
  ensure_resource('concat::fragment', 'mit_krb5::plugins_trailer', {
    target  => $mit_krb5::krb5_conf_path,
    order   => '42plugins_trailer',
    content => "\n",
  })
}
