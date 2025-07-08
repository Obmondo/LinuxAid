# @summary Class for managing LVM setup with LV creation
#
# @param lvs Hash of Logical Volumes to manage.
# The hash keys are the LV names, and the values are hashes with the following keys:
#   - ensure: Ensure state for the LV, such as present or absent.
#   - vg_name: Name of the volume group.
#   - pv_name: (Optional) Physical volume path.
#   - fs_type: Filesystem type for the LV.
#   - lv_size: Size of the logical volume.
#
class common::lvm (
  Hash[String, Struct[{
    ensure  => Eit_types::Ensure,
    vg_name => String,
    pv_name => Optional[Stdlib::Absolutepath],
    fs_type => Eit_types::FilesystemType,
    lv_size => String,
    }]
  ] $lvs = {}
) {
  $lvs.each |$lv_name, $lv_options| {
    lvm::volume { $lv_name:
      ensure => $lv_options['ensure'],
      vg     => $lv_options['vg_name'],
      pv     => $lv_options['pv_name'],
      fstype => $lv_options['fs_type'],
      size   => $lv_options['lv_size']
    }
  }
}
