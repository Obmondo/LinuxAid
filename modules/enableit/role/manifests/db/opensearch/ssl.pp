# @summary SSL settings for Opensearch, used when `ssl` is enabled
#
# @param combined_pem The contents of the combined SSL PEM file, both certificate and private key. Defaults to undef.
#
# @groups ssl combined_pem
#
class role::db::opensearch::ssl (
  Optional[String] $combined_pem = undef,
) {
}
