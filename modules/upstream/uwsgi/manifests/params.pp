# == Class: uwsgi::params
# Default parameters for configuring and installing
# uwsgi
#
# === Authors:
# - Josh Smeaton <josh.smeaton@gmail.com>
#
class uwsgi::params {
    $package_name        = 'uwsgi'
    $package_ensure      = 'present'
    $package_provider    = 'pip'
    $service_name        = 'uwsgi'
    $service_ensure      = true
    $service_enable      = true
    $manage_service_file = true
    $config_file         = '/etc/uwsgi/emperor.ini'
    $tyrant              = true
    $log_file            = '/var/log/uwsgi/emperor.log'
    $log_rotate          = 'no'
    $config_directory    = '/etc/uwsgi'
    $plugins_directory   = '/etc/uwsgi/plugins'
    $app_directory       = '/etc/uwsgi/vassals.d'
    $service_file_ensure = 'present'
    $user                = 'uwsgi'
    $group               = 'uwsgi'
    $setup_python        = false
    $purge               = true

    case $::osfamily {
        'Redhat', 'Amazon': {
            $pidfile       = '/var/run/uwsgi/uwsgi.pid'
            $socket        = '/var/run/uwsgi/uwsgi.socket'
            $service_file  = '/etc/init.d/uwsgi'
            $service_file_template = 'uwsgi/uwsgi_service-redhat.erb'
            $service_mode  = '0555'
        }
        'Debian': {
            $pidfile       = '/run/uwsgi/uwsgi.pid'
            $socket        = '/run/uwsgi/uwsgi.socket'
            $service_file = '/etc/init/uwsgi.conf'
            $service_file_template = 'uwsgi/uwsgi_upstart.conf.erb'
            $service_mode = '0644'
        }
        default: {
          fail("${::operatingsystem} not supported")
        }
    }
}
