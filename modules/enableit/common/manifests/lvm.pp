# LVM Setup
# Only LV setup for now
# common::mounts is too specific for luks and now its bit ugly
class common::lvm (
  Hash[
    String,
    Struct[{
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
