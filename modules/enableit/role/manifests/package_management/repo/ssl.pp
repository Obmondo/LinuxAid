# @summary SSL settings for the package management repo, used when `ssl` is enabled
#
# @param cert The SSL certificate to use. Defaults to undef.
#
# @param key The SSL key to use. Defaults to undef.
#
# @groups ssl cert, key
#
class role::package_management::repo::ssl (
  Optional[String] $cert = undef,
  Optional[String] $key  = undef,
) {
}
