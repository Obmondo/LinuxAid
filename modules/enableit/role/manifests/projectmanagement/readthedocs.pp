
# @summary Class for managing the Read The Docs project
#
# @param ssl_combined_pem The path to the SSL combined PEM file.
#
# @param upstream_git_repo The upstream git repository. Defaults to 'https://github.com/rtfd/readthedocs.org.git'.
#
# @param revision The version revision to use. Defaults to '2.7.0'.
#
# @param bind The IP address to bind to. Defaults to '0.0.0.0'.
#
# @param port The port to use. Defaults to 8000.
#
# @param manage_haproxy Whether to manage the HAProxy configuration. Defaults to true.
#
# @param public_domainname The public domain name.
#
class role::projectmanagement::readthedocs (
  String                  $ssl_combined_pem,
  Eit_types::URL          $upstream_git_repo  = 'https://github.com/rtfd/readthedocs.org.git',
  Eit_types::SimpleString $revision           = '2.7.0',
  Eit_types::Host         $bind               = '0.0.0.0',
  Stdlib::Port            $port               = 8000,
  Boolean                 $manage_haproxy     = true,
  Stdlib::Fqdn            $public_domainname,
) inherits ::role {

  confine($facts['os']['family'] != 'RedHat',
          'Only RedHat family is supported')
  confine_systemd()

  'profile::projectmanagement::readthedocs'.contain
}
