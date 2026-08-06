
# @summary Class for managing the Web Ruby role
#
class role::web::ruby () inherits role::web {

  contain role::appeng::passenger
}
