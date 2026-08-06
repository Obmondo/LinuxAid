
# @summary Setup easyredmine
# Partially broken, because redmine module is not maintained any more.
# We might have to patch to support easyredmine as well.
# Currently it tries to download redmine from different URL
# So what we need to do is
# Take over the redmine plugin
# Add support for easyredmine
# puppet 6 style
# Any more ?

# @param servername The fully qualified domain name of the server.
#
# @param location NOTE: Local filesystem path where the easyredmine zip file has been placed manually, BEFORE running puppet. Necessary as one cannot just download easyredmine.
#
# @groups server servername, location
#
class role::projectmanagement::easyredmine (
  Stdlib::Fqdn     $servername,
  # NOTE: Local filesystem path where the easyredmine zip file has been placed manually,
  # BEFORE running puppet. Necessary as one cannot just download easyredmine.
  Stdlib::Unixpath $location,
) inherits role::projectmanagement {

  profile::projectmanagement::easyredmine.contain
  role::db::pgsql.contain
}
