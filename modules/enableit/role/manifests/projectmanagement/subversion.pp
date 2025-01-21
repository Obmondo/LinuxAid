# Subversion
class role::projectmanagement::subversion (
  Boolean                        $enable      = true,
  Optional[Stdlib::Fqdn]         $domain      = 'svn.hbkworkd.com',
  Optional[Stdlib::Absolutepath] $path        = '/var/www/svn',
  Optional[Stdlib::Absolutepath] $dir         = '/repos',
  Optional[Stdlib::Absolutepath] $backup_dir  = '/var/www/svn/backup',
  Optional[String]               $user        = undef,
  Optional[String]               $password    = undef,
  Optional[Boolean]              $noop_value  = false,
) {

  include profile::projectmanagement::subversion
  contain role::web::apache
}
