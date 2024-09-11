# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include thinlinc::session
class thinlinc::session (
  ThinLinc::HexRGB         $background_color = $::thinlinc::session_background_color,
  Stdlib::Absolutepath     $background_image = $::thinlinc::session_background_image,
  ThinLinc::KeyboardLayout $keyboard_layout  = $::thinlinc::session_keyboard_layout,
) inherits ::thinlinc {

  file { "${thinlinc::install_dir}/etc/conf.d/sessionstart.hconf":
    ensure  => 'file',
    content => epp('thinlinc/conf.d/sessionstart.hconf.epp'),
  }

}
