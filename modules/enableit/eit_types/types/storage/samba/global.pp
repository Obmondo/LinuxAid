type Eit_types::Storage::Samba::Global = Struct[{
  printing               => Optional[String],
  printcap_cache_time    => Optional[Integer],
  cups_options           => Optional[String],
  usershare_allow_guests => Optional[Boolean],
  include                => Optional[Stdlib::Absolutepath],
  logon_path             => Optional[String],
  logon_home             => Optional[String],
  logon_drive            => Optional[Stdlib::Windowspath],
  usershare_max_shares   => Optional[Integer],
  wins_support           => Optional[Boolean],
  kerberos_method        => Optional[Enum['system keytab']],
  dfree_command          => Optional[Stdlib::Absolutepath],
}]
