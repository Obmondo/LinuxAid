# Class: gitolite::params
#
# Description
#   This class is designed to carry default parameters for
#   Class: gitolite.
#
# Parameters:
#  $gt_uid: username under the context where gitolite will run
#  $gt_gid: group under the context where gitolite will run
#  $gt_repo_base: base directory where gitolite will keep configuration.
#  $gt_repo_dir: directory where git repositories will be stored.
#  $gt_vhost: default vhost when installing gitweb.
#  $gt_site_name: default friendly name on gitweb to be displayed.
#  $gt_client_package: packages to be installed for the client
#  $gt_server_package: packages to be installed for the server
#  $gt_httpd_conf_dir: default directory for httpd management
#  $gt_httpd_var_dir: default directory for apache logs
#  $gt_httpd_uid: default uid to be used for apache management in this module.
#  $gt_gitweb_root: root directory where the gitweb documents are installed.
#  $gt_gitweb_spath: directory for static files served by gitweb.
#  $gt_gitweb_binary: cgi for serving gitweb
#
# Actions:
#   This module does not perform any actions.
#
# Requires:
#   This module has no requirements.
#
# Sample Usage:
#   This method should not be called directly.
class gitolite::params {
  $gt_uid          = 'gitolite'
  $gt_gid          = 'gitolite'
  $gt_repo_base    = '/opt/git'
  $gt_repo_dir     = "${gt_repo_base}/repositories"
  $gt_vhost        = "git.${::domain}"
  $gt_site_name    = "${::fqdn} Git Repository"
  $gt_hooks_module = 'gitolite_hooks'

  case $::operatingsystem {
    fedora,redhat,oel,centos: {
      $gt_client_package = ['perl-Error', 'perl-Git', 'git']
      $gt_server_package = [ 'gitweb', 'gitolite' ]
      $gt_httpd_conf_dir = '/etc/httpd/conf.d'
      $gt_httpd_var_dir  = '/var/log/httpd'
      $gt_httpd_uid      = 'apache'
      $gt_gitweb_root    = '/var/www/git/'
      $gt_gitweb_spath   = 'static/'
      $gt_gitweb_binary  = 'gitweb.cgi'
    }
    debian,ubuntu: {
      $gt_client_package = ['git']
      $gt_server_package = [ 'gitweb', 'gitolite' ]
      $gt_httpd_conf_dir = '/etc/apache2/conf.d'
      $gt_httpd_var_dir  = '/var/log/apache2'
      $gt_httpd_uid      = 'www-data'
      $gt_gitweb_root    = '/usr/share/gitweb/'
      $gt_gitweb_spath   = './'
      $gt_gitweb_binary  = 'index.cgi'
    }
    default: {
      fail("The git module is not configured for use with ${::operatingsystem}")
    }
  }
}
