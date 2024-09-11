# Class redmine::config
class redmine::config {

  require 'apache'

  File {
    owner => $apache::params::user,
    group => $apache::params::group,
    mode  => '0644'
  }

  file { $redmine::webroot:
    ensure => link,
    target => $redmine::install_dir
  }

  # user switching makes passenger run redmine as the owner of the startup file
  # which is config.ru or config/environment.rb depending on the Rails version
  file { [
      "${redmine::install_dir}/config.ru",
      "${redmine::install_dir}/config/environment.rb"]:
    ensure => 'present',
  }

  file { [
      "${redmine::install_dir}/files",
      "${redmine::install_dir}/tmp",
      "${redmine::install_dir}/tmp/sockets",
      "${redmine::install_dir}/tmp/thumbnails",
      "${redmine::install_dir}/tmp/cache",
      "${redmine::install_dir}/tmp/test",
      "${redmine::install_dir}/tmp/pdf",
      "${redmine::install_dir}/tmp/sessions",
      "${redmine::install_dir}/public/plugin_assets",
      "${redmine::install_dir}/log"]:
    ensure  => 'directory',
  }

  file { "${redmine::install_dir}/config/database.yml":
    ensure  => present,
    content => template('redmine/database.yml.erb')
  }

  file { "${redmine::install_dir}/config/configuration.yml":
    ensure  => present,
    content => template('redmine/configuration.yml.erb')
  }

  if $redmine::www_subdir {
    file_line { 'redmine_relative_url_root':
      path  => "${redmine::install_dir}/config/environment.rb",
      line  => "Redmine::Utils::relative_url_root = '/${redmine::www_subdir}'",
      match => '^Redmine::Utils::relative_url_root',
    }
  } else {
    if $redmine::create_vhost {
      apache::vhost { 'redmine':
        port            => '80',
        docroot         => "${redmine::webroot}/public",
        servername      => $redmine::vhost_servername,
        serveraliases   => $redmine::vhost_aliases,
        options         => 'Indexes FollowSymlinks ExecCGI',
        custom_fragment => "
          RailsBaseURI /
          PassengerPreStart http://${redmine::vhost_servername}
          ${redmine::vhost_custom_fragment}
          ",
      }
    }
  }

  # Log rotation
  file { '/etc/logrotate.d/redmine':
    ensure  => present,
    content => template('redmine/redmine-logrotate.erb'),
    owner   => 'root',
    group   => 'root'
  }

}
