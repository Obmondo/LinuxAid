# Samba
class common::storage::samba (
  Boolean                           $enable = false,
  String                            $workgroup,
  String                            $server_string,
  Enum['ADS','user']                $security,
  Optional[Boolean]                 $local_master      = undef,
  Optional[Boolean]                 $domain_master     = undef,
  Optional[Boolean]                 $preferred_master  = undef,
  Optional[Eit_types::Domain]       $realm             = undef,
  Optional[Boolean]                 $load_printers     = undef,
  Optional[Stdlib::Absolutepath]    $printcap_name,
  Eit_types::Storage::Samba::Shares $shares,
  Array[String]                     $listen_interfaces = [],
  Enum[
    'Never',
    'Bad User',
    'Bad Password',
    'Bad Uid'
  ]                                 $map_to_guest      = 'Never',
  Array $idmap_config    = [],
  Eit_types::Storage::Samba::Global $global_options,
) {

  confine($enable, $security == 'ADS', !$domain_master and !$realm,
          'Domain Master and Realm is required for ADS Security')

  if $enable {
    contain ::profile::storage::samba
  }
}
