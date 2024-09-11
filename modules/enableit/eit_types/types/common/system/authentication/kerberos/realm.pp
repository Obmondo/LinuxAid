type Eit_types::Common::System::Authentication::Kerberos::Realm = Struct[{
  default_domain => Eit_types::Domain,
  kdc            => Eit_types::Common::System::Authentication::Kerberos::Kdc,
  admin_server   => Eit_types::Domain,
}]
