# Selinux fcontext
# Only Supporting this for now.
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
