# @summary Simple settings to use
# @param mainconf
#   Augeas location of the dnf or yum configuration file.
#   The default is set into hiera according to the package_provider
#   being yum or dnf.
#
class yum::settings (
  Enum['/etc/yum.conf','/etc/dnf/dnf.conf'] $mainconf,
) {}
