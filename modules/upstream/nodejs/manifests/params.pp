class nodejs::params {
  $npmrc_auth                  = undef
  $npmrc_config                = undef
  $nodejs_debug_package_ensure = 'absent'
  $nodejs_package_ensure       = 'installed'
  $repo_ensure                 = 'present'
  $repo_pin                    = undef
  $repo_priority               = 'absent'
  $repo_proxy                  = 'absent'
  $repo_proxy_password         = 'absent'
  $repo_proxy_username         = 'absent'
  $repo_version                = ($facts['os']['family'] == 'RedHat' and $facts['os']['release']['major'] == '7') ? {
    true    => '16',
    default => '20',
  }
  $use_flags                   = ['npm', 'snapshot']

  $cmd_exe_path = $facts['os']['family'] ? {
    'Windows' => "${facts['os']['windows']['system32']}\\cmd.exe",
    default   => undef,
  }

  case $facts['os']['family'] {
    'Debian': {
      $manage_package_repo       = true
      $nodejs_debug_package_name = 'nodejs-dbg'
      $nodejs_dev_package_name   = 'libnode-dev'
      $nodejs_dev_package_ensure = 'absent'
      $nodejs_package_name       = 'nodejs'
      $npm_package_ensure        = 'absent'
      $npm_package_name          = 'npm'
      $npm_path                  = '/usr/bin/npm'
      $repo_class                = 'nodejs::repo::nodesource'
      $package_provider          = undef
    }
    'RedHat': {
      $manage_package_repo       = true
      $nodejs_debug_package_name = 'nodejs-debuginfo'
      $nodejs_dev_package_name   = 'nodejs-devel'
      $nodejs_dev_package_ensure = 'absent'
      $nodejs_package_name       = 'nodejs'
      $npm_package_ensure        = 'absent'
      $npm_package_name          = 'npm'
      $npm_path                  = '/usr/bin/npm'
      $repo_class                = 'nodejs::repo::nodesource'
      $package_provider          = undef
    }
    'Suse': {
      $manage_package_repo       = false
      $nodejs_debug_package_name = 'nodejs-debuginfo'
      $nodejs_dev_package_name   = 'nodejs-devel'
      $nodejs_dev_package_ensure = 'absent'
      $nodejs_package_name       = 'nodejs'
      $npm_package_ensure        = 'installed'
      $npm_package_name          = 'npm'
      $npm_path                  = '/usr/bin/npm'
      $repo_class                = undef
      $package_provider          = undef
    }
    'Archlinux': {
      $manage_package_repo       = false
      $nodejs_debug_package_name = undef
      $nodejs_dev_package_name   = undef
      $nodejs_dev_package_ensure = 'absent'
      $nodejs_package_name       = 'nodejs'
      $npm_package_ensure        = 'installed'
      $npm_package_name          = 'npm'
      $npm_path                  = '/usr/bin/npm'
      $repo_class                = undef
      $package_provider          = undef
    }
    'FreeBSD': {
      $manage_package_repo       = false
      $nodejs_debug_package_name = undef
      $nodejs_dev_package_name   = 'www/node-devel'
      $nodejs_dev_package_ensure = 'absent'
      $nodejs_package_name       = 'www/node'
      $npm_package_ensure        = 'installed'
      $npm_package_name          = 'www/npm'
      $npm_path                  = '/usr/local/bin/npm'
      $repo_class                = undef
      $package_provider          = undef
    }
    'OpenBSD': {
      $manage_package_repo       = false
      $nodejs_debug_package_name = undef
      $nodejs_dev_package_name   = undef
      $nodejs_dev_package_ensure = 'absent'
      $nodejs_package_name       = 'node'
      $npm_package_ensure        = 'absent'
      $npm_package_name          = false
      $npm_path                  = '/usr/local/bin/npm'
      $repo_class                = undef
      $package_provider          = undef
    }
    'Darwin': {
      $manage_package_repo       = false
      $nodejs_debug_package_name = undef
      $nodejs_dev_package_name   = 'nodejs-devel'
      $nodejs_dev_package_ensure = 'absent'
      $nodejs_package_name       = 'nodejs'
      $npm_package_ensure        = 'installed'
      $npm_package_name          = 'npm'
      $npm_path                  = '/opt/local/bin/npm'
      $repo_class                = undef
      $package_provider          = 'macports'
    }
    'Windows': {
      $manage_package_repo       = false
      $nodejs_debug_package_name = undef
      $nodejs_dev_package_name   = undef
      $nodejs_dev_package_ensure = 'absent'
      $nodejs_package_name       = 'nodejs'
      $npm_package_ensure        = 'absent'
      $npm_package_name          = 'npm'
      $npm_path                  = '"C:\Program Files\nodejs\npm.cmd"'
      $repo_class                = undef
      $package_provider          = 'chocolatey'
    }
    'Gentoo': {
      $manage_package_repo       = false
      $nodejs_debug_package_name = undef
      $nodejs_dev_package_name   = undef
      $nodejs_dev_package_ensure = 'absent'
      $nodejs_package_name       = 'net-libs/nodejs'
      $npm_package_ensure        = 'absent'
      $npm_package_name          = false
      $npm_path                  = '/usr/bin/npm'
      $repo_class                = undef
      $package_provider          = undef
    }
    default: {
      fail("The ${module_name} module is not supported on a ${facts['os']['name']} distribution.")
    }
  }
}
