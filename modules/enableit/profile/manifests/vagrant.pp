# Vagrant Profile
class profile::vagrant(
  Optional[Hash]
    $plugins              = {},
  Optional[Hash]
    $box                  = {},
  Optional[Enum['virtualbox', 'kvm']]
    $backend              = 'virtualbox'
) {

  confine ($backend != 'virtualbox', "${backend} is not supported as of now")

  if $backend == 'virtualbox' {
    include ::profile::virtualbox
  }

  include vagrant

  create_resources('::vagrant::plugin', $plugins)
  create_resources('::vagrant::box', $box)
}
