# Docker registry role
class role::util::docker_registry (
  Eit_types::Email $admin_email
) inherits role::util {
  firewall { '000 allow http':
    proto => 'tcp',
    dport => 80,
    jump  => 'accept',
  }
  class { '::docker_distribution':
    log_fields               => {
      service     => 'registry',
      environment => 'production'
    }
    ,
    log_hooks_mail_disabled  => false,
    log_hooks_mail_levels    => ['panic', 'error'],
    log_hooks_mail_to        => $admin_email,
    filesystem_rootdirectory => '/srv/registry',
    http_addr                => ':443',
    http_tls                 => true,
  }

}
