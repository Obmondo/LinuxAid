# == Define: mit_krb5::appdefaults
#
# Configure appdefaults section of krb5.conf
#
# === Authors
#
# Patrick Mooney <patrick.f.mooney@gmail.com>
# Hristo Mohamed <hristo.mohamed@gmail.com>
#
# === Copyright
#
# Copyright 2013 Patrick Mooney.
# Copyright (c) IN2P3 Computing Centre, IN2P3, CNRS
#

define mit_krb5::appdefaults(
  $debug                 = '',
  $ticket_lifetime       = '',
  $renew_lifetime        = '',
  $forwardable           = '',
  $krb4_convert          = '',
  $ignore_afs            = '',
) {
  include mit_krb5
  ensure_resource('concat::fragment', 'mit_krb5::appdefaults_header', {
    target  => $mit_krb5::krb5_conf_path,
    order   => '50appdefauls_header',
    content => "\n[appdefaults]",
  })
  concat::fragment { "mit_krb5::appdefaults::${title}":
    target  => $mit_krb5::krb5_conf_path,
    order   => "51appdefault-${title}",
    content => template('mit_krb5/appdefaults.erb'),
  }
}


