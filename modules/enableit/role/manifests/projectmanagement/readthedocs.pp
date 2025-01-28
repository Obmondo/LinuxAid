# Read The Docs
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
