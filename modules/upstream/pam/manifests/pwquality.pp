# @summary Manage pwquality.conf
#
# @example
#   This class is included by the pam class for platforms which use it.
#
# @param config_file
#   Path to pwquality.conf.
# @param config_file_owner
#   Owner for pwquality.conf
# @param config_file_group
#   Group for pwquality.conf
# @param config_file_mode
#   Mode for config_file.
# @param config_file_source
#   String with source path to a pwquality.conf
# @param config_file_template
#   Template to render pwquality.conf
# @param config_d_dir
#   Path to pwquality.conf.d directory.
# @param config_d_dir_owner
#   Owner for pwquality.conf.d
# @param config_d_dir_group
#   Group for pwquality.conf.d
# @param config_d_dir_mode
#   Mode for pwquality.conf.d
# @param purge_config_d_dir
#   Boolean to purge the pwquality.conf.d directory.
# @param purge_config_d_dir_ignore
#   A glob or array of file names to ignore when purging pwquality.conf.d
#
# @param difok
#   The pwquality.conf 'difok' option
# @param minlen
#   The pwquality.conf 'minlen' option
# @param dcredit
#   The pwquality.conf 'dcredit' option
# @param ucredit
#   The pwquality.conf 'ucredit' option
# @param lcredit
#   The pwquality.conf 'lcredit' option
# @param ocredit
#   The pwquality.conf 'ocredit' option
# @param minclass
#   The pwquality.conf 'minclass' option
# @param maxrepeat
#   The pwquality.conf 'maxrepeat' option
# @param maxsequence
#   The pwquality.conf 'maxsequence' option
# @param maxclassrepeat
#   The pwquality.conf 'maxclassrepeat' option
# @param gecoscheck
#   The pwquality.conf 'gecoscheck' option
# @param dictcheck
#   The pwquality.conf 'dictcheck' option
# @param usercheck
#   The pwquality.conf 'usercheck' option
# @param usersubstr
#   The pwquality.conf 'usersubstr' option
# @param enforcing
#   The pwquality.conf 'enforcing' option
# @param badwords
#   The pwquality.conf 'badwords' option
# @param dictpath
#   The pwquality.conf 'dictpath' option
# @param retry
#   The pwquality.conf 'retry' option
# @param enforce_for_root
#   The pwquality.conf 'enforce_for_root' option
# @param local_users_only
#   The pwquality.conf 'local_users_only' option
#
class pam::pwquality (
  Stdlib::Absolutepath $config_file = '/etc/security/pwquality.conf',
  String[1] $config_file_owner = 'root',
  String[1] $config_file_group = 'root',
  Stdlib::Filemode $config_file_mode = '0644',
  Optional[Stdlib::Filesource] $config_file_source = undef,
  String[1] $config_file_template = 'pam/pwquality.conf.erb',
  Stdlib::Absolutepath $config_d_dir = '/etc/security/pwquality.conf.d',
  String[1] $config_d_dir_owner = 'root',
  String[1] $config_d_dir_group = 'root',
  Stdlib::Filemode $config_d_dir_mode = '0755',
  Boolean $purge_config_d_dir = true,
  Optional[Variant[String[1], Array[String[1]]]] $purge_config_d_dir_ignore = undef,
  Integer[0] $difok = 1,
  Integer[6] $minlen = 8,
  Integer $dcredit = 0,
  Integer $ucredit = 0,
  Integer $lcredit = 0,
  Integer $ocredit = 0,
  Integer[0] $minclass = 0,
  Integer[0] $maxrepeat = 0,
  Integer[0] $maxsequence = 0,
  Integer[0] $maxclassrepeat = 0,
  Integer[0] $gecoscheck = 0,
  Integer[0] $dictcheck = 1,
  Integer[0] $usercheck = 1,
  Integer[0] $usersubstr = 0,
  Integer[0] $enforcing = 1,
  Optional[Array[String[1]]] $badwords = undef,
  Optional[Stdlib::Absolutepath] $dictpath = undef,
  Integer[0] $retry = 1,
  Optional[Boolean] $enforce_for_root = undef,
  Optional[Boolean] $local_users_only = undef,
) {
  include pam

  if $config_file_source {
    $_config_file_content = undef
  } else {
    $_config_file_content = template($config_file_template)
  }

  file { 'pwquality.conf':
    ensure  => 'file',
    path    => $config_file,
    owner   => $config_file_owner,
    group   => $config_file_group,
    mode    => $config_file_mode,
    source  => $config_file_source,
    content => $_config_file_content,
    require => Package[$pam::package_name],
  }

  file { 'pwquality.conf.d':
    ensure  => 'directory',
    path    => $config_d_dir,
    owner   => $config_d_dir_owner,
    group   => $config_d_dir_group,
    mode    => $config_d_dir_mode,
    purge   => $purge_config_d_dir,
    recurse => $purge_config_d_dir,
    ignore  => $purge_config_d_dir_ignore,
    require => Package[$pam::package_name],
  }
}
