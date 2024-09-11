# atat classes
class role::customers::enableit::atat {

  include role::storage::backuphost
  include role::storage::s3
  include role::web::haproxy
  include role::package_management::repo
}
