# Class redmine::download
class redmine::download {

  # Install redmine from source

  Exec {
    cwd  => '/usr/src',
    path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ]
  }

  if $redmine::provider == 'wget' {
    stdlib::ensure_packages([ 'tar', 'wget' ])
    warning('The wget provider is deprecated and will be removed in the next major version.')
    warning('Consider using a VCS like git or svn instead.')
    exec { 'redmine_source':
      command => "wget -O redmine.tar.gz ${redmine::download_url}",
      creates => '/usr/src/redmine.tar.gz',
      require => Package['wget'],
    }
    -> exec { 'extract_redmine':
      command => "mkdir -p ${redmine::install_dir} && tar xvzf redmine.tar.gz --strip-components=1 -C ${redmine::install_dir}",
      creates => $redmine::install_dir,
      require => Package['tar'],
    }
  } elsif $redmine::provider == 'file' {
    # EasyRedmine
    redmine::easyredmine.include
  } else {
    stdlib::ensure_packages($redmine::params::provider_package)
    vcsrepo { 'redmine_source':
      revision => $redmine::params::version,
      source   => $redmine::download_url,
      provider => $redmine::provider,
      path     => $redmine::install_dir,
      require  => Package[$redmine::params::provider_package]
    }

  }
}
