# @summary Class for managing the RustFS Storage role
#
# @param data_dir The host directory where backup data is stored.
# @param access_key The S3 access key ID.
# @param secret_key The S3 secret access key.
# @param enable Whether to enable and manage the rustfs component.
# @param expose Whether to expose the service via HAProxy.
# @param version The rustfs/rustfs image tag to run, e.g. '1.0.7'. Bumping it
#   is all an upgrade needs; puppet recreates the container on the new image.
#   https://github.com/rustfs/rustfs/releases
# @param listen_address Address the container publishes its ports on. Keep it
#   at 127.0.0.1 where HAProxy on the same host fronts the service, so the S3
#   API and console are not reachable without going through the proxy.
# @param oidc Single sign-on for the RustFS console via an OpenID Connect
#   provider such as Keycloak. Unset (the default) leaves OIDC off.
#   config_url is the provider's .well-known/openid-configuration URL, and
#   client_id/client_secret belong to a confidential client whose valid
#   redirect URIs include
#   https://<rustfs host>/rustfs/admin/v3/oidc/callback/*. claim_name is the
#   token claim holding the RustFS policy name; the console only opens for
#   consoleAdmin. It is set explicitly because RustFS does not apply its
#   documented "policy" default (rustfs/rustfs#2298).
#
# @example Usage
#   include role::storage::rustfs
#
# @example Keycloak SSO
#   role::storage::rustfs::oidc:
#     config_url: https://auth.example.com/realms/example/.well-known/openid-configuration
#     client_id: rustfs
#     client_secret: ENC[PKCS7,...]
#
class role::storage::rustfs (
  String[1]            $access_key,
  String[1]            $secret_key,
  Stdlib::Unixpath     $data_dir,
  Boolean              $enable        = true,
  Boolean              $expose        = false,
  String[1]            $listen_address = '0.0.0.0',
  Eit_types::Rustfs::Version $version  = '1.0.7',
  Optional[Eit_types::Oidc] $oidc = undef,
) inherits role::storage {
  contain role::virtualization::docker
  contain profile::storage::rustfs
  if $expose {
    include role::web::haproxy
  }
}
