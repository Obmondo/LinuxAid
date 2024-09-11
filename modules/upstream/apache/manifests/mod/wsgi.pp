# @summary
#   Installs and configures `mod_wsgi`.
# 
# @param wsgi_restrict_embedded
#   Enable restrictions on use of embedded mode.
# 
# @param wsgi_socket_prefix
#   Configure directory to use for daemon sockets.
# 
# @param wsgi_python_path
#   Additional directories to search for Python modules.
# 
# @param wsgi_python_home
#   Absolute path to Python prefix/exec_prefix directories.
# 
# @param wsgi_python_optimize
#   Enables basic Python optimisation features.
# 
# @param wsgi_application_group
#   Sets which application group WSGI application belongs to.
# 
# @param package_name
#   Names of package that installs mod_wsgi.
# 
# @param mod_path
#   Defines the path to the mod_wsgi shared object (.so) file.
# 
# @see https://github.com/GrahamDumpleton/mod_wsgi for additional documentation.
# @note Unsupported platforms: SLES: all; RedHat: all; CentOS: all; OracleLinux: all; Scientific: all
class apache::mod::wsgi (
  Optional[String] $wsgi_restrict_embedded         = undef,
  Optional[String] $wsgi_socket_prefix             = $apache::params::wsgi_socket_prefix,
  Optional[Stdlib::Absolutepath] $wsgi_python_path = undef,
  Optional[Stdlib::Absolutepath] $wsgi_python_home = undef,
  Optional[Integer] $wsgi_python_optimize          = undef,
  Optional[String] $wsgi_application_group         = undef,
  Optional[String] $package_name                   = undef,
  Optional[String] $mod_path                       = undef,
) inherits apache::params {
  include apache
  if ($package_name != undef and $mod_path == undef) or ($package_name == undef and $mod_path != undef) {
    fail('apache::mod::wsgi - both package_name and mod_path must be specified!')
  }

  if $package_name != undef {
    if $mod_path =~ /\// {
      $_mod_path = $mod_path
    } else {
      $_mod_path = "${apache::lib_path}/${mod_path}"
    }
    ::apache::mod { 'wsgi':
      package => $package_name,
      path    => $_mod_path,
    }
  }
  else {
    ::apache::mod { 'wsgi': }
  }

  # Template uses:
  # - $wsgi_restrict_embedded
  # - $wsgi_socket_prefix
  # - $wsgi_python_path
  # - $wsgi_python_home
  $parameters = {
    'wsgi_restrict_embedded'  => $wsgi_restrict_embedded,
    'wsgi_socket_prefix'      => $wsgi_socket_prefix,
    'wsgi_python_home'        => $wsgi_python_home,
    'wsgi_python_path'        => $wsgi_python_path,
    'wsgi_application_group'  => $wsgi_application_group,
    'wsgi_python_optimize'    => $wsgi_python_optimize,
  }

  file { 'wsgi.conf':
    ensure  => file,
    path    => "${apache::mod_dir}/wsgi.conf",
    mode    => $apache::file_mode,
    content => epp('apache/mod/wsgi.conf.epp', $parameters),
    require => Exec["mkdir ${apache::mod_dir}"],
    before  => File[$apache::mod_dir],
    notify  => Class['apache::service'],
  }
}
