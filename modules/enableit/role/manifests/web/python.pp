# Web Python role
class role::web::python (
  String $url = undef,
  Enum['::role::appeng::uwsgi', '::role::appeng::passenger']
    $variant = '::role::appeng::uwsgi',
  ) inherits role::web {

  case $variant {
    '::role::appeng::uwsgi' : {
      class { '::role::appeng::uwsgi' : url => $url }
    }
    '::role::appeng::passenger' : {
      class { '::role::appeng::passenger' : url => $url }
    }
    default: {
      fail('Unsupported')
    }
  }
}
