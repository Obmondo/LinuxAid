# == Type: vagrant::command
#
# Wrapper type for setting required environment for executing vagrant commands
#
# === Parameters
#
#
# === Examples
#
#
# === Copyright
#
# Copyright 2015 North Development AB
#

define vagrant::command (
  $path         = undef,
  $user         = $::id,
  $command      = $title,
  $unless       = undef,
  $only_if      = undef,
  $timeout      = 0
) {

  include vagrant::params

  $exec_command = $::kernel ? {
    'windows' => "C:\\Windows\\System32\\cmd.exe /C ${command}",
    default => "su -l ${user} -c '${command}'"
  }

  $exec_path = $path ? {
    undef => $vagrant::params::path,
    default => $path
  }

  exec { $title:
    command => $exec_command,
    path    => $exec_path,
    timeout => $timeout
  }

  if $unless != undef {
    $unless_command = $::kernel ? {
      'windows' => "C:\\Windows\\System32\\cmd.exe /C '${unless}'",
      default => "su -l ${user} -c '${unless}'"
    }
    Exec[$title] { unless => $unless_command }
  }

  if $only_if != undef {
    $only_if_command = $::kernel ? {
      'windows' => "C:\\Windows\\System32\\cmd.exe /C '${only_if}'",
      default => "su -l ${user} -c '${only_if}'"
    }
    Exec[$title] { only_if => $only_if }
  }
}
