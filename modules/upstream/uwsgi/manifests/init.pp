# == Class: uwsgi
#
# This class installs and configures uWSGI Emperor service. By default,
# it will use pip to install uwsgi, so you need to make sure that pip
# is available on the system. You will also need to ensure that
# the python development headers are installed so that uwsgi can build.
#
# === Parameters
#
# [*package_name*]
#    The package name to install. Default: 'uwsgi'
#
# [*package_ensure*]
#    Package state. Default: 'installed'
#
#    If 'absent' or 'purged', then remove the `service_file` and `config_file`
#    also
#
# [*package_provider*]
#    The provider to use to install the package. Default: 'pip'
#
# [*service_name*]
#    The name of the service to run uwsgi. Default: 'uwsgi'
#
# [*service_file*]
#    The location of the service file. Default: '/etc/init/uwsgi.conf'
#
# [*service_file_mode*]
#    The mode of the service file. Default: '0644'
#
# [*service_template*]
#    The location of the template to generate the *service_file*.
#    Default: 'uwsgi/uwsgi_upstart.conf.erb'
#
# [*service_ensure*]
#    The service state. Default: true
#
# [*service_enable*]
#    The service onboot state. Default: true
#
# [*service_provider*]
#    The service provider. Default: 'upstart'
#    'upstart' is required for the default service_file, and
#    works on RedHat >= 6
#
# [*manage_service_file*]
#    Whether to override the system service file if it exists. Default: true
#
# [*config_file*]
#    The location of the uwsgi config file. Default: '/etc/uwsgi.ini'
#
# [*log_file*]
#    The location of the uwsgi emperor log.
#    Default: '/var/log/uwsgi/uwsgi-emperor.log'
#
# [*log_rotate]
#    Whether or not to deploy a logrotate script.
#    Accepts: 'yes', 'no', 'purge'
#    Default: 'no'
#
# [*app_directory*]
#    Vassal directory for application config files
#
# [*tyrant*]
#   Whether to run the emperor in tyrant mode
#   Default: true
#
# [*install_pip*]
#    Install pip if it's not already installed?
#    Default: true
#
# [*install_python_dev*]
#    Install python header files if not already installed?
#    Default: true
#
# [*python_pip*]
#    Package to be installed for pip
#    Default: 'python-pip'
#
# [*python_dev*]
#    Package to be installed for python headers
#    Default RedHat: 'python-devel'
#    Default Other: 'python-dev'
#
# [*emperor_options*]
#    Extra options to set in the emperor config file
#
# === Authors
# - Josh Smeaton <josh.smeaton@gmail.com>
# - Colin Wood <cwood06@gmail.com>
#
class uwsgi (
    $package_name          = $::uwsgi::params::package_name,
    $package_ensure        = $::uwsgi::params::package_ensure,
    $package_provider      = $::uwsgi::params::package_provider,
    $service_name          = $::uwsgi::params::service_name,
    $service_file          = $::uwsgi::params::service_file,
    $service_file_template = $::uwsgi::params::service_file_template,
    $service_mode          = $::uwsgi::params::service_mode,
    #$service_template      = $::uwsgi::params::service_template,
    $service_ensure        = $::uwsgi::params::service_ensure,
    $service_enable        = $::uwsgi::params::service_enable,
    $service_provider      = $::uwsgi::params::service_provider,
    $manage_service_file   = $::uwsgi::params::manage_service_file,
    $config_file           = $::uwsgi::params::config_file,
    $log_file              = $::uwsgi::params::log_file,
    $log_rotate            = $::uwsgi::params::log_rotate,
    $app_directory         = $::uwsgi::params::app_directory,
    $tyrant                = $::uwsgi::params::tyrant,
    $setup_python          = $::uwsgi::params::setup_python,
    $pidfile               = $::uwsgi::params::pidfile,
    $socket                = $::uwsgi::params::socket,
    $purge                 = $::uwsgi::params::purge,
    $emperor_options       = undef,
    $hiera_hash            = false,
    $user                  = $::uwsgi::params::user,
    $group                 = $::uwsgi::params::group,
    $apps                  = {},
    $plugins               = {},
    $plugins_directory     = $::uwsgi::params::plugins_directory,
    $config_directory      = $::uwsgi::params::config_directory
) inherits uwsgi::params {

    validate_re($log_rotate, '^yes$|^no$|^purge$')
    validate_hash($plugins)
    validate_hash($apps)
    validate_bool($purge)
    validate_absolute_path($plugins_directory)

    class{'::uwsgi::install': }->
    class{'::uwsgi::config': }~>
    class{'::uwsgi::service': }->
    Class['Uwsgi']

    if $hiera_hash {
      create_resources('uwsgi::app', hiera_hash('uwsgi::apps', {}))
    } else {
      create_resources('uwsgi::app', $apps)
    }

    create_resources('uwsgi::plugin', $plugins)


    case $log_rotate {
        'yes': {
            file { '/etc/logrotate.d/uwsgi':
                ensure  => 'file',
                owner   => 'root',
                group   => 'root',
                mode    => '0644',
                content => template('uwsgi/uwsgi_logrotate.erb'),
            }
        }
        'absent', 'purge', 'purged', 'no': {
            file { '/etc/logrotate.d/uwsgi':
                ensure  => 'absent',
            }
        }
        default: {
          fail('Must be either, yes, absent, purge, or purged')
        }
    }

}
