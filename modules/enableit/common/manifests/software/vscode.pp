# Vscode install
class common::software::vscode (
  Boolean           $enable     = false,
  Boolean           $manage     = false,
  Optional[Boolean] $noop_value = undef,
) inherits common {

  if $manage {
    contain profile::software::vscode
  }
}

