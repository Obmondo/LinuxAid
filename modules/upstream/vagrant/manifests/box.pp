# == Type: vagrant::box
#
# Add a vagrant box under the home directory of the specified user.
#
# === Parameters
#
# [*ensure*]
#   Ensurable
#
# [*box*]
#   The name of the box (namevar).
#
# [*user*]
#   The user under which the box will be added. Ignored on Windows
#   systems (current user is assumed).
#
# [*provider*]
#   Vagrant supported provider. Example: virtualbox
#
# [*insecure*]
#   Do not validate SSL certificates
#
# [*force*]
#   Overwrite an existing box if it exists or force removal
#
# [*path*]
#   PATH variable to be used while executing vagrant commands
#
# === Examples
#
# # Add CentOS 7.0 x86_64 with puppet and docker virtualbox
# vagrant::box { 'centos7-puppet-docker':
#   user => 'myuser',
#   source => 'https://dl.dropboxusercontent.com/s/srw2tqh58507wik/CentOS7.box'
# }
#
# === Copyright
#
# Copyright 2015 North Development AB
#

define vagrant::box (
  $ensure       = present,
  $box          = $title,
  $provider     = virtualbox,
  $user         = $::id,
  $clean        = true,
  $insecure     = false,
  $force        = false,
  $version      = undef,
  $source       = '',
  $path         = undef,
  $timeout      = 0
) {

  validate_bool($clean)
  validate_bool($insecure)
  validate_bool($force)

  $check_cmd = "${vagrant::params::vagrant} box list | ${vagrant::params::grep} \"^${box}\s*[(]${provider}\""

  # Parse provided type arguments and construct command option string
  $option_box = " --box ${box}"
  $option_provider = " --provider ${provider}"
  $option_version = $version ? {
    undef   => '',
    default => " --box-version \"${version}\""
  }
  $option_insecure = $insecure ? {
    true => '',
    default => ' --insecure'
  }
  $option_force = $force ? {
    false => '',
    default => ' --force'
  }
  $option_clean = $clean ? {
    false => '',
    default => ' --clean'
  }
  $add_options = "${option_provider}${option_version}${option_insecure}${option_force}${option_clean}"
  $remove_options = "${option_provider}${option_version}${option_force}"
  $update_options = "${option_provider}${option_box}"

  $command_name = "${user}-vagrant-box-${box}"

  vagrant::command { $command_name:
    user    => $user,
    path    => $path,
    timeout => $timeout
  }

  case $ensure {
    'present', 'added': {
      Vagrant::Command[$command_name] {
        unless => $check_cmd,
        command => "vagrant box add ${box} ${source} ${add_options}"
      }
    }
    'absent', 'removed': {
      Vagrant::Command[$command_name] {
        only_if => $check_cmd,
        command => "vagrant box remove ${box} ${remove_options}"
      }
    }
    'latest', 'updated': {
      Vagrant::Command[$command_name] {
        command => "vagrant box update ${update_options}"
      }
    }
    default: { fail("Unsupported value for ensure: ${ensure}") }
  }
}
