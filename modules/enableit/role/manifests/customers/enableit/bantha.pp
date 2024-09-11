# bantha classes
class role::customers::enableit::bantha {

  include role::web::haproxy
  include profile::virtualization::lxc
}
