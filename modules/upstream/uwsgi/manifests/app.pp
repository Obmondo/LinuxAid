# == Define: uwsgi::app
#
# Responsible for creating uwsgi applications. You shouldn't need to use this
# type directly, as the main `uwsgi` class uses this type internally.
#
# === Parameters
#
# [*ensure*]
#    Ensure the config file exists. Default: 'present'
#
# [*template*]
#    The template used to construct the config file.
#    Default: 'uwsgi/uwsgi_app.ini.erb'
#
# [*application_options*]
#    Options to set in the application config file
#
# [*environment_variables*]
#    Extra environment variables to set in the application config file
#
# === Authors
# - Josh Smeaton <josh.smeaton@gmail.com>
# - Colin Wood <cwood06@gmail.com>
#
define uwsgi::app (
  $ensure                = 'present',
  $template              = 'uwsgi/uwsgi_app.ini.erb',
  $application_options   = undef,
  $environment_variables = undef,
  $environment_file      = undef,
){

  include ::uwsgi

  if $environment_file {
    validate_absolute_path($environment_file)
  }

  validate_string($template)

  if $application_options {
    validate_hash($application_options)
  }

  if $environment_variables {
    validate_hash($environment_variables)
  }


  file { "${uwsgi::app_directory}/${title}.ini":
    ensure  => $ensure,
    owner   => $uwsgi::user,
    group   => $uwsgi::group,
    mode    => '0644',
    content => template($template),
  }
}
