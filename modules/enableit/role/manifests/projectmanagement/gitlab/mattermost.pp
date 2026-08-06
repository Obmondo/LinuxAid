# @summary Mattermost settings for GitLab, used when `mattermost` is enabled
#
# @param ssl_cert The SSL certificate for Mattermost. Defaults to the GitLab certificate.
#
# @param ssl_key The SSL key for Mattermost. Defaults to the GitLab key.
#
# @param domain The domain Mattermost is served on. Defaults to the GitLab domain.
#
# @param config Additional Mattermost configuration. Defaults to an empty hash.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @groups mattermost ssl_cert, ssl_key, domain, config, encrypt_params
#
# @encrypt_params ssl_cert, ssl_key
#
class role::projectmanagement::gitlab::mattermost (
  Optional[String] $ssl_cert = $role::projectmanagement::gitlab::ssl_cert,
  Optional[String] $ssl_key  = $role::projectmanagement::gitlab::ssl_key,
  Stdlib::Fqdn     $domain   = $role::projectmanagement::gitlab::domain,
  Hash             $config   = {},

  Eit_types::Encrypt::Params $encrypt_params = [
    'ssl_cert',
    'ssl_key',
  ]
) {
}
