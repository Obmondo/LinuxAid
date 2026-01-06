
# @summary Class for managing the Subversion project management role
#
# @param enable Whether to enable the Subversion service. Defaults to true.
#
# @param domain The domain for the Subversion server. Defaults to 'svn.hbkworkd.com'.
#
# @param path The absolute path to the Subversion installation. Defaults to '/var/www/svn'.
#
# @param dir The absolute path to the repositories directory. Defaults to '/repos'.
#
# @param backup_dir The absolute path to the backup directory. Defaults to '/var/www/svn/backup'.
#
# @param user The username for Subversion authentication. Defaults to undef.
#
# @param password The password for Subversion authentication. Defaults to undef.
#
# @param noop_value Whether to enable noop mode. Defaults to false.
#
# @groups service enable, noop_value
#
# @groups server domain, path, dir, backup_dir
#
# @groups authentication user, password
#
class role::projectmanagement::subversion (
  Boolean                        $enable      = true,
  Optional[Stdlib::Fqdn]         $domain      = 'svn.hbkworkd.com',
  Optional[Stdlib::Absolutepath] $path        = '/var/www/svn',
  Optional[Stdlib::Absolutepath] $dir         = '/repos',
  Optional[Stdlib::Absolutepath] $backup_dir  = '/var/www/svn/backup',
  Optional[String]               $user        = undef,
  Optional[String]               $password    = undef,
  Eit_types::Noop_Value          $noop_value  = false,
) {
  include profile::projectmanagement::subversion
  contain role::web::apache
}
