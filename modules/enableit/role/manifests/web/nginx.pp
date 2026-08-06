
# @summary Class for managing the Nginx web server role
#
# @param __blendable
# Internal parameter for blendable role support. No default value.
#
class role::web::nginx (
  Boolean $__blendable,
) inherits ::role {

  include profile::web::nginx
}
