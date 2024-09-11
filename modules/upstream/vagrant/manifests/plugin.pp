# == Type: vagrant::plugin
#
# Install vagrant plugins.
# Look at https://github.com/mitchellh/vagrant/wiki/Available-Vagrant-Plugins for a list of available plugins.
#
# === Parameters
#
# [*ensure*]
#   Ensurable
#
# [*plugin*]
#   The name of the plugin (namevar).
#
# [*version*]
#   Specific version of the plugin you want to install. Defaults to the current plugin version.
#
# [*prerelease*]
#   Allow to install prerelease versions of this plugin.
#
# [*source*]
#   Use a custom RubyGems repository.
#
# [*entry_point*]
#   The name of the entry point file for loading the plugin.
#
# [*user*]
#   The user to install the plugin for.
#
# [*home*]
#   The home directory of the user to install the plugin for.
#
# [*path*]
#   PATH variable to be used while executing vagrant commands
#
# === Examples
#
# # Install current version
# vagrant::plugin { 'vagrant-hostmanager':
#   user => 'myuser'
# }
#
# # Install specific version
# vagrant::plugin { 'vagrant-hostmanager':
#   user => 'myuser'
#   version => 0.8.0
# }
#
# # Install a pre-release version
# vagrant::plugin { 'vagrant-hostmanager':
#   user => 'myuser'
#   prerelease => true
# }
#
# === Copyright
#
# Copyright 2015 North Development AB
#

define vagrant::plugin (
  $ensure       = present,
  $plugin       = $title,
  $version      = undef,
  $user         = $::id,
  $source       = undef,
  $prerelease   = false,
  $entry_point  = undef,
  $path         = undef,
  $timeout      = 0
) {

  validate_bool($prerelease)

  $check_cmd = "${vagrant::params::vagrant} plugin list | ${vagrant::params::grep} \"^${plugin} \""

  # Parse provided type arguments and construct command option string
  $option_version = $version ? {
    undef   => '',
    default => " --plugin-version \"${version}\""
  }
  $option_prerelease = $prerelease ? {
    true    => ' --plugin-prerelease',
    default => ''
  }
  $option_source = $source ? {
    undef   => '',
    default => " --plugin-source \"${source}\""
  }
  $option_entry_point = $entry_point ? {
    undef   => '',
    default => " --entry-point \"${entry_point}\""
  }
  $install_options = "${option_version}${option_prerelease}${option_source}${option_entry_point}"

  $command_name = "${user}-vagrant-plugin-${plugin}"

  vagrant::command { $command_name:
    user    => $user,
    path    => $path,
    timeout => $timeout
  }

  case $ensure {
    'present', 'installed': {
      Vagrant::Command[$command_name] {
        unless => $check_cmd,
        command => "vagrant plugin install ${plugin} ${install_options}"
      }
    }
    'absent', 'uninstalled': {
      Vagrant::Command[$command_name] {
        only_if => $check_cmd,
        command => "vagrant plugin uninstall ${plugin}"
      }
    }
    'latest', 'updated': {
      Vagrant::Command[$command_name] {
        command => "vagrant plugin update ${plugin}"
      }
    }
    default: { fail("Unsupported value for ensure: ${ensure}") }
  }
}
