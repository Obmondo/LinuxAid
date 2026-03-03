# cron
class profile::system::cron (
  Variant[Boolean, Enum['root-only']] $purge_unmanaged = $common::system::cron::purge_unmanaged,
  Hash                                $jobs            = $common::system::cron::jobs,
) {

  contain ::cron

  if $purge_unmanaged {
    purge { 'cron':
      if => if $purge_unmanaged == 'root-only' {
        [ 'name', '==', 'root' ]
      },
    }
  }

  $jobs.each |$name, $job| {
    profile::cron::job { $name:
      * => $job,
    }
  }

  if $facts['os']['family'] == 'RedHat' {
    # Anacron (cronie-anacron) fails if the anacron folder is missing
    file { '/var/spool/anacron':
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => 'a+rx,u+w'
    }
  }

}
