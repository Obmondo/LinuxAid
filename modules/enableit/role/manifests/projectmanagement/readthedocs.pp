
# @summary Class for managing the Read The Docs project
#
# @param ssl_combined_pem The path to the SSL combined PEM file.
#
# @groups ssl_configuration ssl_combined_pem.
#
class role::projectmanagement::readthedocs (
  String $ssl_combined_pem,
) inherits ::role {

  confine($facts['os']['family'] != 'RedHat',
          'Only RedHat family is supported')
  confine_systemd()

  'profile::projectmanagement::readthedocs'.contain
}
