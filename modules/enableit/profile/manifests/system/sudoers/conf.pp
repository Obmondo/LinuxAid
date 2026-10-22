# sudo conf wrapper
define profile::system::sudoers::conf (
  Eit_types::Ensure                 $ensure     = present,
  Optional[Eit_types::SimpleString] $filename   = undef,
  Integer[0,default]                $priority   = 10,
  Optional[String]                  $content    = undef,
  Optional[String]                  $source     = undef,
  Optional[String]                  $template   = undef,
  Eit_types::Noop_Value             $noop_value = undef,
) {
  $sudoers_d_dir = lookup('common::user_management::authentication::sudo::sudoers_d_dir', Stdlib::Absolutepath, 'first', '/etc/obmondo/sudoers.d')

  $_sudo_conf_name = safe_string($name)

  # Needed to be able to set `noop` for file resources in sudo::conf.
  File {
    noop => $noop_value,
  }

  if (!$content or $content.size == 0) and !$source {
    fail("Broken sudoers rule; content is empty! as well as no source file has been provided name: ${name}")
  }

  # sudo-rs (default sudo on e.g. Ubuntu 26.04) rejects rules with wildcards
  # (`*`, `?`) in command arguments and the `requiretty` setting, and prints a
  # parse error for them on every sudo call. Such rules never take effect
  # there, so remove them on sudo-rs hosts. A lone `*` as the last argument
  # (`/usr/sbin/nginx *`) and `[` are accepted by sudo-rs, so keep those.
  $_sudo_rs_incompatible = $facts.dig('sudo', 'kind') == 'sudo-rs' and $content and $content.split("\n").any |$line| {
    if $line =~ /^\s*Defaults/ {
      $line =~ /\brequiretty\b/
    } elsif $line =~ /^\s*(#|$)/ {
      false
    } else {
      # Strip `user host=(runas) TAGS:` and check each command's arguments
      $line.regsubst(/^[^=]*=\s*(\([^)]*\)\s*)?([A-Z_]+:\s*)*/, '').split(/,\s*(?=\/)/).any |$command| {
        $command.strip.regsubst(/\s+\*$/, '') =~ /^\S+\s+.*[*?]/
      }
    }
  }

  $_ensure = $_sudo_rs_incompatible ? {
    true    => 'absent',
    default => $ensure,
  }

  sudo::conf { $_sudo_conf_name:
    ensure          => $_ensure,
    sudo_config_dir => $sudoers_d_dir,
    sudo_file_name  => $filename,
    content         => $content,
    source          => $source,
    priority        => $priority,
    noop            => $noop_value,
    require         => File[$sudoers_d_dir],
  }
}
