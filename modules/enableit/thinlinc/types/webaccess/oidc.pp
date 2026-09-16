# OpenID Connect providers for ThinLinc Web Access, ThinLinc 4.21 and later.
#
# Keyed by provider name, which is also the default login button text.
type ThinLinc::Webaccess::Oidc = Hash[
  Pattern[/\A[a-zA-Z0-9_-]+\z/],
  Struct[{
      'username_claim'     => String[1],
      'discovery_url'      => Stdlib::HTTPSUrl,
      'client_id'          => String[1],
      'client_secret_path' => Stdlib::Absolutepath,
      'button_text'        => Optional[String[1]],
      'icon_path'          => Optional[Stdlib::Absolutepath],
      'prompt'             => Optional[Enum['none', 'login', 'consent', 'select_account']],
      'scope'              => Optional[Array[String[1]]],
  }],
]
