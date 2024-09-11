# RubyonRails role
class role::webframeworks::rubyonrails (
  Optional[Enum['::role::db::mysql', '::role::db::pgsql']] $db = '::role::db::mysql',
  Enum['::role::appeng::passenger'] $ruby = '::role::appeng::passenger',
  Enum['::role::web::apache'] $http_server = '::role::web::apache',
  Enum[4, 5] $version = 5,
  Enum['gem', 'package'] $provider = 'package',
  Boolean $manage_web_server = false,
) inherits ::role::webframeworks {

  if $db {
    class { $db: }
  }

  $_http_server = $http_server ? {
    '::role::web::apache' => 'apache',
  }

  case $ruby {
    '::role::appeng::passenger' : {
      class { '::profile::passenger' :
        http_server        => $_http_server,
        passenger_version  => $version,
        passenger_provider => $provider,
        manage_web_server  => $manage_web_server,
      }
    }
    default : {
      fail ( "${ruby} not supported, Please contact EnableIT.dk")
    }
  }
}
