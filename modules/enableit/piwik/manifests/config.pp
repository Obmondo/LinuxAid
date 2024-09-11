# Piwik config class
class piwik::config (
  $force_https,
  $use_forwarded_for,
  $use_forwarded_host,
) {

  ini_setting {
    default:
      ensure  => present,
      section => 'General',
      path    => "${::piwik::path}/config/config.ini.php";

    'force_https':
      setting => 'assume_secure_protocol',
      value   => Integer($force_https);

    'use_forwarded_for':
      ensure  => if $use_forwarded_for { 'present' } else { 'absent' },
      setting => 'proxy_host_headers[]',
      value   => 'HTTP_X_FORWARDED_FOR';

    'use_forwarded_host':
      ensure  => if $use_forwarded_host { 'present' } else { 'absent' },
      setting => 'proxy_host_headers[]',
      value   => 'HTTP_X_FORWARDED_HOST';
  }
}
