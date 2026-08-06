
# @summary Class for managing the Subversion project management role
#
class role::projectmanagement::subversion {
  include profile::projectmanagement::subversion
  contain role::web::apache
}
