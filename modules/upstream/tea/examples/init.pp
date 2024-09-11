# lint:ignore:autoloader_layout
class tea {
  # lint:endignore
  class { '::tea::ports':
    any_port  => 5001,
    unp_port  => 5002,
    priv_port => 1001,
  }

}
