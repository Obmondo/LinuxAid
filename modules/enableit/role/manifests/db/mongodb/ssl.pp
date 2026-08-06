# @summary SSL settings for MongoDB, used when `ssl` is enabled
#
# @param ca The SSL CA certificate path. Defaults to undef.
#
# @param key The SSL key path. Defaults to undef.
#
# @groups ssl ca, key
#
class role::db::mongodb::ssl (
  Optional[Stdlib::Absolutepath] $ca  = undef,
  Optional[Stdlib::Absolutepath] $key = undef,
) {
}
