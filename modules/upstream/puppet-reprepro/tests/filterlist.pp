class { 'reprepro': }

reprepro::filterlist { 'lenny-backports':
  repository => 'dev',
  packages   => ['git install', 'git-email install'],
  basedir    => '/foo/bar',
}
