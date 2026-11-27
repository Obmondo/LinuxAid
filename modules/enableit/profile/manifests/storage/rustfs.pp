# @summary RustFS storage profile
#
# @param data_dir The host directory where backup data is stored.
# @param access_key The S3 access key ID.
# @param secret_key The S3 secret access key.
# @param env_vars Additional hash of environment variables for the container.
# @param enable Whether to enable and manage the rustfs component.
# @param listen_address Address the container publishes its ports on.
# @param version The rustfs/rustfs image tag to run.
# @param oidc OpenID Connect settings for console SSO, or undef to leave it off.
#
class profile::storage::rustfs (
  String[1]            $access_key    = $role::storage::rustfs::access_key,
  String[1]            $secret_key    = $role::storage::rustfs::secret_key,
  Boolean              $enable        = $role::storage::rustfs::enable,
  Stdlib::Unixpath     $data_dir      = $role::storage::rustfs::data_dir,
  Hash                 $env_vars      = {},
  String[1]            $listen_address = $role::storage::rustfs::listen_address,
  Eit_types::Rustfs::Version $version  = $role::storage::rustfs::version,
  Optional[Eit_types::Oidc] $oidc = $role::storage::rustfs::oidc,
) {
  $_oidc_env = $oidc ? {
    undef   => {},
    default => {
      'RUSTFS_IDENTITY_OPENID_ENABLE'        => 'true',
      'RUSTFS_IDENTITY_OPENID_CONFIG_URL'    => $oidc['config_url'],
      'RUSTFS_IDENTITY_OPENID_CLIENT_ID'     => $oidc['client_id'],
      'RUSTFS_IDENTITY_OPENID_CLIENT_SECRET' => $oidc['client_secret'],
      'RUSTFS_IDENTITY_OPENID_DISPLAY_NAME'  => pick($oidc['display_name'], 'SSO'),
      'RUSTFS_IDENTITY_OPENID_SCOPES'        => pick($oidc['scopes'], ['openid', 'profile', 'email']).join(','),
      'RUSTFS_IDENTITY_OPENID_CLAIM_NAME'    => pick($oidc['claim_name'], 'policy'),
    },
  }

  # 1. Manage RustFS
  class { 'rustfs':
    access_key     => $access_key,
    secret_key     => $secret_key,
    enable         => $enable,
    data_dir       => $data_dir,
    env_vars       => $_oidc_env + $env_vars,
    listen_address => $listen_address,
    version        => $version,
  }
}
