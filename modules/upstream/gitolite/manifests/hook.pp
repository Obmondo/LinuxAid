define gitolite::hook {
  $repo = $name

  file { "${gitolite::params::gt_repo_dir}/${repo}.git/hooks":
    ensure  => directory,
    recurse => true,
    owner   => $gitolite::params::gt_uid,
    group   => $gitolite::params::gt_gid,
    source  => "puppet:///modules/${gitolite::params::gt_hooks_module}/${repo}",
    require => Class['gitolite::server']
  }
}
