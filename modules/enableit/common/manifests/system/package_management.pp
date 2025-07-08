# @summary Class for managing system package management
#
class common::system::package_management () inherits ::common::system {
  contain ::common::system::package_management::guix
}
