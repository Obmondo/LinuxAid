# sudo conf wrapper
define profile::system::sudoers::conf (
  Eit_types::Ensure                 $ensure        = present,
  Optional[Eit_types::SimpleString] $filename      = undef,
  Integer[0,default]                $priority      = 10,
  Optional[String]                  $content       = undef,
  Optional[String]                  $source        = undef,
  Optional[String]                  $template      = undef,
  Boolean                           $noop_value    = true,
) {

  $sudoers_d_dir = lookup('common::system::authentication::sudo::sudoers_d_dir', Stdlib::Absolutepath, 'first', '/etc/obmondo/sudoers.d')

  $_sudo_conf_name = safe_string($name)

  # Needed to be able to set `noop` for file resources in sudo::conf.
  File {
    noop => $noop_value,
  }

  if (!$content or $content.size == 0) and !$source {
    fail("Broken sudoers rule; content is empty! as well as no source file has been provided
name: ${name}
")
  }

  sudo::conf { $_sudo_conf_name:
    ensure          => $ensure,
    sudo_config_dir => $sudoers_d_dir,
    sudo_file_name  => $filename,
    content         => $content,
    source          => $source,
    priority        => $priority,
    noop            => $noop_value,
    require         => File[$sudoers_d_dir],
  }

}
