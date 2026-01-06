# @summary Class for managing common Samba storage configuration
#
# @param enable Boolean flag to enable or disable Samba. Default is false.
#
# @param workgroup The workgroup name.
#
# @param server_string The server string description.
#
# @param security Security mode, either 'ADS' or 'user'.
#
# @param local_master Optional boolean indicating if the server is a local master. Default is undef.
#
# @param domain_master Optional boolean indicating if the server is a domain master. Default is undef.
#
# @param preferred_master Optional boolean indicating if the server is a preferred master. Default is undef.
#
# @param realm Optional realm domain; must be of type Eit_types::Domain.
#
# @param load_printers Optional boolean to load printers; default is undef.
#
# @param printcap_name Optional absolute path for printcap; default is undef.
#
# @param shares Shares configuration of type Eit_types::Storage::Samba::Shares.
#
# @param listen_interfaces List of interfaces to listen on; defaults to empty array.
#
# @param map_to_guest Enum for mapping to guest; defaults to 'Never'.
#
# @param idmap_config Array of ID mapping configurations; defaults to empty array.
#
# @param global_options Global options of type Eit_types::Storage::Samba::Global.
#
# @groups master_configuration local_master, domain_master, preferred_master.
#
# @groups global_settings global_options, map_to_guest, idmap_config, shares, security, enable.
#
# @groups network_settings listen_interfaces, workgroup, server_string, realm.
#
# @groups printer_settings load_printers, printcap_name.
#
class common::storage::samba (
  Boolean                          $enable = false,
  String                           $workgroup,
  String                           $server_string,
  Enum['ADS','user']                $security,
  Optional[Boolean]                 $local_master      = undef,
  Optional[Boolean]                 $domain_master     = undef,
  Optional[Boolean]                 $preferred_master  = undef,
  Optional[Eit_types::Domain]       $realm             = undef,
  Optional[Boolean]                 $load_printers     = undef,
  Optional[Stdlib::Absolutepath]    $printcap_name,
  Eit_types::Storage::Samba::Shares $shares,
  Array[String]                    $listen_interfaces = [],
  Enum[
    'Never',
    'Bad User',
    'Bad Password',
    'Bad Uid'
  ]                                 $map_to_guest      = 'Never',
  Array                              $idmap_config    = [],
  Eit_types::Storage::Samba::Global $global_options,
) {
  confine($enable, $security == 'ADS', !$domain_master and !$realm, 'Domain Master and Realm is required for ADS Security')
  if $enable {
    contain ::profile::storage::samba
  }
}
