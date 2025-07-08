# @summary Class for managing SELinux fcontext
#
# @param manage Flag to manage SELinux context. Defaults to false.
#
# @param enable Enable SELinux. Defaults to the value of $facts['selinux'].
#
# @param enforce Enforce SELinux policy. Defaults to false.
#
# @param fcontext Hash of fcontext definitions. Defaults to empty hash.
#
# @param enable_setroubleshoot Enable setroubleshoot. Defaults to false.
#
class common::system::selinux (
  Boolean            $manage                = false,
  Boolean            $enable                = $facts['selinux'],
  Boolean            $enforce               = false,
  Hash[String, Hash] $fcontext              = {},
  Boolean            $enable_setroubleshoot = false,
) {
  if $manage and $facts['os']['family'] == 'RedHat' {
    include ::profile::system::selinux
  }
}
