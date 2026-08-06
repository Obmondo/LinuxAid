# @summary Kibana settings for Elasticsearch, used when `kibana` is enabled
#
# @param username The Kibana user for connecting to Elasticsearch.
#
# @param password The password for the Kibana user.
#
# @param ssl_combined_pem The combined PEM used when Kibana is exposed over SSL.
#
# @param elasticsearch The cert and key Kibana presents to Elasticsearch.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @groups kibana username, password, ssl_combined_pem, elasticsearch, encrypt_params
#
# @encrypt_params username, password
#
class role::db::elasticsearch::kibana (
  Optional[String] $username         = undef,
  Optional[String] $password         = undef,
  Optional[String] $ssl_combined_pem = undef,
  Optional[Hash]   $elasticsearch    = undef,

  Eit_types::Encrypt::Params $encrypt_params = [
    'username',
    'password',
  ]
) {
}
