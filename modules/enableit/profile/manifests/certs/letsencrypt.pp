# LetsEncrupt CA Signing
class profile::certs::letsencrypt (
  Eit_types::Email $email          = $::common::certs::letsencrypt::email,
  Boolean          $epel           = false,
  Enum[
    'production',
    'staging'
  ]                $ca             = $::common::certs::letsencrypt::ca,
  Integer          $keep_log_files = 30,
) {

  # Use staging URL if set, otherwise use defaults (as the value is then undef)
  $letsencrypt_ca = if $ca == 'staging' {
    { 'server' => 'https://acme-staging-v02.api.letsencrypt.org/directory' }
  }

  file {
    [
      '/etc/ssl/private/letsencrypt.updates',
      '/etc/letsencrypt/live',
      '/var/www',
      '/var/www/letsencrypt',
    ]:
    ensure => directory,
      ;

    [
      '/etc/obmondo/certs',
      '/etc/obmondo/certs/domains',
    ]:
      # ensure that we purge unmanaged files
      ensure  => directory,
      purge   => true,
      recurse => true,
      ;
  }

  file {
    '/etc/letsencrypt/accounts/':
      ensure => directory,
      mode   => '0700',
      owner  => 'root',
      group  => 'root',
      ;
  }

  if $facts['os']['name'] == 'Ubuntu' and $facts['os']['release']['full'] < '20.04' {
    contain ::apt

    apt::ppa { 'ppa:certbot/certbot': }
  }

  package::install([
    'obmondo-scripts-common',
    'obmondo-letsencrypt-hooks',
  ], {
    ensure => latest,
  })

  class { '::letsencrypt' :
    configure_epel    => $epel,
    renew_cron_ensure => absent,
    email             => $email,
    config            => merge($letsencrypt_ca, {
      # Handle only last 30 log files of letsencrypt
      'max-log-backups' => $keep_log_files,
    }),
    require           => File['/var/www/letsencrypt'],
  }

  # NOTE: we are running certbot renew command as a service, rather then cronjob
  service { 'certbot.timer':
    ensure => 'running',
    enable => true,
  }

  # Remove the `certbot` logrotate rule, which does not work with `max-log-backup`, see below links
  # https://community.letsencrypt.org/t/certbot-max-log-backups-not-working-as-expected/53090/2
  # https://github.com/certbot/certbot/issues/5575
  # https://www.clearos.com/clearfoundation/social/community/letsencrypt-log-rotation

  # and have deleted the old files manually in the logdir, since max-backup-logdir can only manage the give no of days logfile
  # so we need to delete the obsolete log files
  logrotate::rule { 'certbot':
    ensure => 'absent',
  }

  # Remove certbot cron that came from package.
  # Cause it has bug
  file { '/etc/cron.d/certbot':
    ensure => absent,
  }
}
