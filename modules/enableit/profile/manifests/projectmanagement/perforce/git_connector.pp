# Helix Git Connector
#
# https://www.perforce.com/manuals/helix-for-git/Content/Helix4Git/Home-helix4git.html
class profile::projectmanagement::perforce::git_connector (
  Perforce::Version    $version        = $::role::projectmanagement::perforce::git_connector::version,
  Stdlib::Port         $service_port   = $::role::projectmanagement::perforce::service_port,
  Stdlib::Absolutepath $repos_dir      = $::role::projectmanagement::perforce::git_connector::repos_dir,
  Perforce::LogFile    $gconn_log_file = $::role::projectmanagement::perforce::git_connector::gconn_log_file,
  Perforce::LogFile    $p4gc_log_file  = $::role::projectmanagement::perforce::git_connector::p4gc_log_file,
) inherits ::profile::projectmanagement::perforce {

  $_version_suffix  = ".el${facts['os']['release']['major']}"
  $_git_user_home   = '/var/lib/git'
  $_gconn_log_level = 1
  $_p4gc_log_level  = 1

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
    home       => $_git_user_home,
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
        "time=${_gconn_log_level}",
        "gconn=${_gconn_log_level}",
      ]
    },
    reposDir      => $repos_dir,
    p4User        => 'gconn-user',
    p4Port        => String($service_port),
    p4TicketsFile => '/opt/perforce/git-connector/.p4tickets',
    p4TrustFile   => '/opt/perforce/git-connector/.p4trust',
    authKeysFile  => "${_git_user_home}/.ssh/authorized_keys",
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
        "time=${_p4gc_log_level}",
        "gconn=${_p4gc_log_level}",
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
    }.stdlib::to_json_pretty(true, {
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
