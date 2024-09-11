# @summary Manage faillock.conf
#
# @param config_file
#   The faillock config path
# @param config_file_owner
#   The faillock config owner
# @param config_file_group
#   The faillock config group
# @param config_file_mode
#   The faillock config mode
# @param config_file_template
#   The faillock config template
# @param config_file_source
#   The faillock config source
# @param dir
#   The faillock 'dir' config option
# @param audit_enabled
#   The faillock 'audit' config option
# @param silent
#   The faillock 'silent' config option
# @param no_log_info
#   The faillock 'no_log_info' config option
# @param local_users_only
#   The faillock 'local_users_only' config option
# @param deny
#   The faillock 'deny' config option
# @param fail_interval
#   The faillock 'fail_interval' config option
# @param unlock_time
#   The faillock 'unlock_time' config option
# @param even_deny_root
#   The faillock 'even_deny_root' config option
# @param root_unlock_time
#   The faillock 'root_unlock_time' config option
# @param admin_group
#   The faillock 'admin_group' config option
# 
class pam::faillock (
  Stdlib::Absolutepath $config_file = '/etc/security/faillock.conf',
  String[1] $config_file_owner = 'root',
  String[1] $config_file_group = 'root',
  Stdlib::Filemode $config_file_mode = '0644',
  String[1] $config_file_template = 'pam/faillock.conf.erb',
  Optional[Stdlib::Filesource] $config_file_source = undef,
  Stdlib::Absolutepath $dir = '/var/run/faillock',
  Optional[Boolean] $audit_enabled = undef,
  Optional[Boolean] $silent = undef,
  Optional[Boolean] $no_log_info = undef,
  Optional[Boolean] $local_users_only = undef,
  Integer[0] $deny = 3,
  Integer[0] $fail_interval = 900,
  Integer[0] $unlock_time = 600,
  Optional[Boolean] $even_deny_root = undef,
  Integer[0] $root_unlock_time = $unlock_time,
  Optional[String[1]] $admin_group = undef,
) {
  include pam

  if $config_file_source {
    $_config_file_content = undef
  } else {
    $_config_file_content = template($config_file_template)
  }

  file { 'faillock.conf':
    ensure  => 'file',
    path    => $config_file,
    owner   => $config_file_owner,
    group   => $config_file_group,
    mode    => $config_file_mode,
    content => $_config_file_content,
    source  => $config_file_source,
    require => Package[$pam::package_name],
  }
}
