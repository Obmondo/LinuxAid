
# @summary Class for managing the Web PHP role
#
class role::web::php () inherits role::web {

  contain role::appeng::phpfpm
}
