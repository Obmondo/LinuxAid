# OpenID Connect provider settings for SSO, e.g. Keycloak (used by role::storage::rustfs)
type Eit_types::Oidc = Struct[{
  config_url             => Stdlib::HTTPSUrl,
  client_id              => String[1],
  client_secret          => String[1],
  Optional[display_name] => String[1],
  Optional[scopes]       => Array[String[1], 1],
  Optional[claim_name]   => String[1],
}]
