# Azure walinuxagent
class profile::software::walinuxagent (
  Boolean                           $enable                 = $common::software::walinuxagent::enable,
  Boolean                           $manage                 = $common::software::walinuxagent::manage,
  Optional[Boolean]                 $noop_value             = $common::software::walinuxagent::noop_value,
  Eit_types::SimpleString           $__linux_azure_package  = $common::software::walinuxagent::__linux_azure_package,
  Eit_types::SimpleString           $__linux_azure_service  = $common::software::walinuxagent::__linux_azure_service,
  Optional[String]                  $waagent_memory_limit   = $common::software::walinuxagent::waagent_memory_limit,
) {

  package { $__linux_azure_package:
    ensure  => ensure_present($enable),
    noop    => $noop_value,
    require => unless $enable { Service[$__linux_azure_service] },
  }

  $_services = ([$__linux_azure_service] + if $enable { [] } else {
    # This is apparently also installed and may be left behind
    'omid.service'
  }).delete_undef_values

  service { $_services:
    ensure  => ensure_service($enable),
    noop    => $noop_value,
    require => if $enable { Package[$__linux_azure_package] },
  }

  if $waagent_memory_limit {
    common::services::systemd { 'azure-walinuxagent-logcollector.slice':
      ensure => ensure_present($enable),
      unit   => {
        'Description'         => 'Slice for Azure VM Agent Periodic Log Collector',
        'DefaultDependencies' => 'no',
        'Before'              => 'slices.target',
      },
      slice  => {
        'MemoryAccounting' => 'yes',
        'MemoryLimit'      => $waagent_memory_limit,
      },
    }
  }

  if $manage and $enable {
    # Remove all the logrotate snippets. We need to use tidy to use the glob, as
    # the omsagent file has a random UUID in the name
    tidy { 'walinuxagent logrotate files':
      path    => '/etc/logrotate.d',
      matches => [
        'waagent-extn.logrotate',
        'waagent.logrotate',
      ],
      recurse => 1,
      noop    => $noop_value,
    }

    logrotate::rule { 'walinux_agents':
      ensure        => ensure_present($enable),
      path          => ['/var/log/waagent.log'],
      rotate_every  => 'daily',
      rotate        => 30,
      missingok     => true,
      ifempty       => false,
      compress      => true,
      delaycompress => false,
      dateext       => true,
      copytruncate  => true,
    }
  }
}
