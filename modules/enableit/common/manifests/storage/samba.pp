# samba shares
class common::storage::samba (
  Boolean                           $enable = false,
  String                            $workgroup,
  String                            $server_string,
  Enum['ADS']                       $security,
  Boolean                           $local_master,
  Boolean                           $domain_master,
  Boolean                           $preferred_master,
  Eit_types::Domain                 $realm,
  Boolean                           $load_printers,
  Optional[Stdlib::Absolutepath]    $printcap_name,
  Enum['system keytab']             $kerberos_method,
  Eit_types::Storage::Samba::Shares $shares,
  Array[String]                     $listen_interfaces = [],
  Boolean                           $override_dfree = true,
  Array $idmap_config = [],
) {

  if $enable {
    contain ::profile::storage::samba
  }
}
