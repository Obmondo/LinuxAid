# Main piwik class
class piwik (
  Stdlib::Absolutepath $path,
  String $user,
  Enum['latest'] $version,
  Boolean $force_https,
  Boolean $use_forwarded_for,
  Boolean $use_forwarded_host,
) {

  class { '::piwik::install':
    path    => $path,
    user    => $user,
    version => $version,
  }

  class { '::piwik::config':
    force_https => $force_https,
    require     => Class['::piwik::install'],
  }
}
