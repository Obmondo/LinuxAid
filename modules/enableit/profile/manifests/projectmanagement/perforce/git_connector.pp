# Helix Git Connector
#
# https://www.perforce.com/manuals/helix-for-git/Content/Helix4Git/Home-helix4git.html
class profile::projectmanagement::perforce::git_connector (
  Perforce::Version    $version         = $::role::projectmanagement::perforce::git_connector::version,
  Stdlib::Port         $service_port    = $::role::projectmanagement::perforce::git_connector::service_port,
  Eit_types::User      $p4_gconn_user   = $::role::projectmanagement::perforce::git_connector::p4_gconn_user,
  Stdlib::Absolutepath $git_user_home   = $::role::projectmanagement::perforce::git_connector::git_user_home,
  Stdlib::Absolutepath $gconn_dir       = $::role::projectmanagement::perforce::git_connector::gconn_dir,
  Stdlib::Absolutepath $repos_dir       = $::role::projectmanagement::perforce::git_connector::repos_dir,
  Stdlib::Absolutepath $log_dir         = $::role::projectmanagement::perforce::git_connector::log_dir,
  Perforce::LogFile    $gconn_log_file  = $::role::projectmanagement::perforce::git_connector::gconn_log_file,
  Perforce::LogLevel   $gconn_log_level = $::role::projectmanagement::perforce::git_connector::gconn_log_level,
  Perforce::LogFile    $p4gc_log_file   = $::role::projectmanagement::perforce::git_connector::p4gc_log_file,
  Perforce::LogLevel   $p4gc_log_level  = $::role::projectmanagement::perforce::git_connector::p4gc_log_level,
) inherits ::profile::projectmanagement::perforce {

  $_version_suffix = ".el${facts.dig('os', 'release', 'major')}"

  $versionrelease = $version.split('-')

  yum::versionlock { 'helix-git-connector':
    ensure  => present,
    version => $versionrelease[0],
    release => "${versionrelease[1]}${_version_suffix}.*",
    epoch   => 0,
    arch    => 'x86_64',
  }

  ssh::server::match_block { 'git':
    options => {
      'AuthorizedKeysCommand'     => '/usr/bin/gconn-ssh-auth.sh %t %k',
      'AuthorizedKeysCommandUser' => 'git',
    }
  }

  group { 'gconn-auth':
    ensure => present,
    system => true,
  }

  user { 'git':
    ensure     => present,
    groups     => [
      'gconn-auth',
      'perforce',
    ],
    home       => $git_user_home,
    shell      => '/bin/bash',
    comment    => 'Helix GitConnector',
    managehome => true,
    system     => true,
    require    => Group['gconn-auth'],
  }

  $_gconn_conf = {
    log           => {
      path => $gconn_log_file,
      levels => [
        "time=${gconn_log_level}",
        "gconn=${gconn_log_level}",
      ]
    },
    reposDir      => $repos_dir,
    p4User        => $p4_gconn_user,
    p4Port        => String($service_port),
    p4TicketsFile => '/opt/perforce/git-connector/.p4tickets',
    p4TrustFile   => '/opt/perforce/git-connector/.p4trust',
    authKeysFile  => "${git_user_home}/.ssh/authorized_keys",
    # authKeysFile  => 'none',
    gitExecPath   => '/bin',
    envPath       => '/usr/bin:/usr/local/bin:/opt/perforce/git-connector/bin',
    authGroup     => 'gconn-auth',
    serverId      => "gconn-${facts['networking']['fqdn']}",
  }
  $_p4gc_conf = {
    log => {
      path   => $p4gc_log_file,
      levels => [
        "time=${p4gc_log_level}",
        "gconn=${p4gc_log_level}",
      ],
    }
  }

  file { '/opt/perforce/git-connector/gconn.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'gconn-auth',
    mode    => '0440',
    content => {
      gconn => $_gconn_conf,
      p4gc  => $_p4gc_conf,
    }.to_json_pretty(true, {
      indent => '    ',
    }),
    require => Group['gconn-auth'],
  }

  file { $repos_dir:
    ensure  => directory,
    owner   => 'git',
    group   => 'gconn-auth',
    mode    => '2770',
    require => [
      User['git'],
      Group['gconn-auth'],
    ],
  }

}
