# Configure ThinLinc session shadowing
#
class thinlinc::shadowing (
  ThinLinc::ShadowMode $shadow_mode = $::thinlinc::shadowing_shadow_mode,
  Optional[Array[String]] $allowed_shadowers = $::thinlinc::shadowing_allowed_shadowers,
) inherits ::thinlinc {

  file { "${thinlinc::install_dir}/etc/conf.d/shadowing.hconf":
    ensure  => 'file',
    content => epp('thinlinc/conf.d/shadowing.hconf.epp'),
    notify  => Service['vsmserver'],
  }

}
