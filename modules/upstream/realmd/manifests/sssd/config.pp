# == Class realmd::sssd::config
#
# This class is called from realmd for SSSD service configuration.
#
class realmd::sssd::config {
  if $realmd::manage_sssd_config {
    $_sssd_config = $realmd::sssd_config

    file { $realmd::sssd_config_file:
      content => template('realmd/sssd.conf.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => $realmd::sssd_config_file_mode,
      notify  => Exec['force_config_cache_rebuild'],
    }

    exec { 'force_config_cache_rebuild':
      path        => '/usr/bin:/usr/sbin:/bin',
      command     => "rm -f ${realmd::sssd_config_cache_file}",
      refreshonly => true,
    }
  }
}
