# @summary This class wraps *cron::install* for ease of use
# @param service_name Can be set to define a different cron service name.
# @param package_name Can be set to install a different cron package.
# @param manage_package Can be set to disable package installation.
# @param manage_service Defines if puppet should manage the service.
# @param service_ensure Defines if the service should be running.
# @param service_enable Defines if the service should be enabled at boot.
# @param users_allow A list of users which are exclusively able to create, edit, display, or remove crontab files. Only used if manage_users_allow == true.
# @param users_deny A list of users which are prohibited from create, edit, display, or remove crontab files. Only used if manage_users_deny == true.
# @param manage_users_allow If the /etc/cron.allow should be managed.
# @param manage_users_deny If the /etc/cron.deny should be managed.
# @param allow_deny_mode Specify the cron.allow/deny file mode.
# @param merge The `lookup()` merge method to use with cron job hiera lookups.
# @param manage_crontab Whether to manage /etc/crontab
# @param crontab_shell The value for SHELL in /etc/crontab
# @param crontab_path The value for PATH in /etc/crontab
# @param crontab_mailto The value for MAILTO in /etc/crontab
# @param crontab_home The value for HOME in /etc/crontab
# @param crontab_run_parts Define sadditional cron::run_parts resources
# @param file_mode The file mode for the system crontab file
# @param dir_mode The file mode for the cron directories
#
# @example simply include the module
#  include cron
#
# @example include it but don't manage the cron package
#  class { 'cron':
#    manage_package => false,
#  }
class cron (
  String[1]            $service_name,
  String[1]            $package_name,
  Boolean              $manage_package          = true,
  Boolean              $manage_service          = true,
  Cron::Service_ensure $service_ensure          = 'running',
  Cron::Service_enable $service_enable          = true,
  Cron::Package_ensure $package_ensure          = 'installed',
  Array[Cron::User]    $users_allow             = [],
  Array[Cron::User]    $users_deny              = [],
  Boolean              $manage_users_allow      = false,
  Boolean              $manage_users_deny       = false,
  Stdlib::Filemode     $allow_deny_mode         = '0644',
  Enum['deep', 'first', 'hash', 'unique'] $merge = 'hash',
  Boolean              $manage_crontab          = false,
  Stdlib::Absolutepath $crontab_shell           = '/bin/bash',
  String[1]            $crontab_path            = '/sbin:/bin:/usr/sbin:/usr/bin',
  String[1]            $crontab_mailto          = 'root',
  Optional[Stdlib::Absolutepath] $crontab_home  = undef,
  Cron::Run_parts      $crontab_run_parts       = {},
  Stdlib::Filemode     $file_mode       = '0644',
  Stdlib::Filemode     $dir_mode        = '0755',
) {
  contain 'cron::install'
  contain 'cron::service'

  Class['cron::install'] -> Class['cron::service']

  # Manage cron.allow and cron.deny
  if $manage_users_allow {
    file { '/etc/cron.allow':
      ensure  => file,
      mode    => $allow_deny_mode,
      owner   => 'root',
      group   => 0,
      content => epp('cron/users.epp', { 'users' => $users_allow }),
    }
  }

  if $manage_users_deny {
    file { '/etc/cron.deny':
      ensure  => file,
      mode    => $allow_deny_mode,
      owner   => 'root',
      group   => 0,
      content => epp('cron/users.epp', { 'users' => $users_deny }),
    }
  }

  if $manage_crontab {
    # Template uses:
    # - $crontab_shell
    # - $crontab_path
    # - $crontab_mailto
    # - $crontab_home
    # - $crontab_run_parts
    file { '/etc/crontab':
      ensure  => file,
      owner   => 'root',
      group   => 0,
      mode    => $file_mode,
      content => epp('cron/crontab.epp'),
    }

    $crontab_run_parts.each |String $r, Hash $r_params| {
      file { "/etc/cron.${r}":
        ensure => directory,
        owner  => 'root',
        group  => 0,
        mode   => $dir_mode,
        before => File['/etc/crontab'],
      }
    }
  }

  # Create jobs from hiera

  $cron_job = lookup('cron::job', Optional[Hash], $merge, {})
  $cron_job.each | String $t, Hash $params | {
    cron::job { $t:
      * => $params,
    }
  }

  $cron_job_multiple = lookup('cron::job::multiple', Optional[Hash], $merge, {})
  $cron_job_multiple.each | String $t, Hash $params | {
    cron::job::multiple { $t:
      * => $params,
    }
  }

  $cron_hourly = lookup('cron::hourly', Optional[Hash], $merge, {})
  $cron_hourly.each | String $t, Hash $params | {
    cron::hourly { $t:
      * => $params,
    }
  }

  $cron_daily = lookup('cron::daily', Optional[Hash], $merge, {})
  $cron_daily.each | String $t, Hash $params | {
    cron::daily { $t:
      * => $params,
    }
  }

  $cron_weekly = lookup('cron::weekly', Optional[Hash], $merge, {})
  $cron_weekly.each | String $t, Hash $params | {
    cron::weekly { $t:
      * => $params,
    }
  }

  $cron_monthly = lookup('cron::monthly', Optional[Hash], $merge, {})
  $cron_monthly.each | String $t, Hash $params | {
    cron::monthly { $t:
      * => $params,
    }
  }
}
