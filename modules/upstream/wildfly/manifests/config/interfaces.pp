#
# Change wildfly interface configuration
#
define wildfly::config::interfaces($inet_address_value){

  case $wildfly::mode {
    'domain': {
      $incl_file = $wildfly::host_config
      $root = 'host'
    }
    default: {
      $incl_file = $wildfly::config
      $root = 'server'
    }
  }

  augeas { $name:
    lens    => 'Xml.lns',
    incl    => "${wildfly::dirname}/${wildfly::mode}/configuration/${incl_file}",
    changes => "set ${root}/interfaces/interface[#attribute/name='${name}']/inet-address/#attribute/value ${inet_address_value}",
    onlyif  => "match ${root}/interfaces/interface[#attribute/name='${name}']/inet-address[#attribute/value='${inet_address_value}'] size == 0"
  }

}
