# lint:ignore:autoloader_layout
class tea::ports (
# lint:endignore
  Tea::Port  $any_port =  5000,
  Tea::UnprivilegedPort $unp_port = 7000,
  Tea::PrivilegedPort $priv_port =  1000,
  ) {
  notify { 'any_port': message => "this port can be anything: ${any_port}" }
  notify { 'unp_port': message => "this port needs to be above 1024: ${unp_port}" }
  notify { 'priv_port': message => "this port needs to be below 1024: ${priv_port}" }

}
