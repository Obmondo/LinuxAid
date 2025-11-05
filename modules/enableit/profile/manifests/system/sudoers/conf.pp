# sudo conf wrapper
define profile::system::sudoers::conf (
  Optional[Eit_types::SimpleString] $filename      = undef,
  Eit_types::Ensure                 $ensure        = present,
  Integer[0,default]                $priority      = 10,
  Optional[String]                  $content       = undef,
  Optional[String]                  $source        = undef,
  Optional[String]                  $template      = undef,
  Stdlib::Absolutepath              $sudoers_d_dir = $common::system::authentication::sudo::__sudoers_d_dir,
  Boolean                           $noop_value    = true,
) {

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
