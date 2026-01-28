# Python Profile
class profile::python (
  Boolean                            $use_epel           = false,
  Variant[Eit_types::Package_Ensure] $virtualenv         = 'absent',
  Boolean                            $devel              = false,
) {
  # Setup Python
  class { '::python' :
    use_epel   => false,
    virtualenv => $virtualenv,
    dev        => ensure_present($devel),
  }
}
