
# @summary Class for managing the OpenVAS scanner
#
class role::scanner::openvas {

  contain role::virtualization::docker
  contain profile::scanner::openvas
}
