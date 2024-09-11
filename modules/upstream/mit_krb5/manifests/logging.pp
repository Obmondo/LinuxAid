# == Class: mit_krb5::loggin
#
# Add logging section to krb5.conf
#
# === Parameters
#
# As in the main class, only specified parameters will appear in the
# configuration.  System defaults are used for absent parameters.
#
# [*admin_server*]
#   These entries specify how the administrative server is to perform its
#   logging.
#
# [*default*]
#   These entries specify how to perform logging in the absence of explicit
#   specifications otherwise.
#
# [*kdc*]
#   These entries specify how the KDC is to perform its logging.
#
# [*defaults*]
#   Work around the Puppet 2.x limitation of class variables named 'default'.
#   This will override the value of the 'default' parameter, if present.
#
# === Examples
#
#  class { 'mit_krb5::logging':
#    default      = 'FILE:/var/log/krb5libs.log',
#    admin_server = 'FILE:/var/log/kadmind.log',
#    kdc          = 'FILE:/var/log/krb5kdc.log'
#  }
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
class mit_krb5::logging(
  $default      = '',
  $admin_server = '',
  $kdc          = '',
  $defaults     = '',
) {

  include ::mit_krb5

  concat::fragment { 'mit_krb5::logging':
    target  => $mit_krb5::krb5_conf_path,
    order   => '00logging',
    content => template('mit_krb5/logging.erb'),
  }
}
