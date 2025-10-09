# == Class: limits
# @summary Manage user and group limits via Puppet
#
# This module manages the limits of the PAM module pam_limits.
#
# @example
#   include limits
#
# @param limits_dir
# Directory for individual limits config files
#
# @param manage_limits_d_dir
# Manage $limits_dir itself
#
# @param purge_limits_d_dir
# Purge $limits_dir
#
# @param limits_file
# Basic limits configuration file
#
# @param manage_limits_file
# Manage $limits_file
#
# @param limits_file_owner
# Owner of $limits_file
#
# @param limits_file_group
# Group $limits_file
#
# @param limits_file_mode
# Mode $limits_file
#
# @param limits_template
# Name of the template to use for $limits_file
#
# @param entries
# limits configuration file(s) entries
#
class limits (
  String[1] $limits_dir,
  Boolean $manage_limits_d_dir,
  Boolean $purge_limits_d_dir,
  String[1] $limits_file,
  Boolean $manage_limits_file,
  String[1] $limits_file_owner,
  String[1] $limits_file_group,
  String[1] $limits_file_mode,
  String[1] $limits_template,
  Optional[Hash[String[1], Hash[Pattern[/\A[a-z][a-z0-9_]*\Z/], Data], 1]] $entries,
) {
  if $manage_limits_d_dir {
    file { $limits_dir:
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      force   => true,
      purge   => $purge_limits_d_dir,
      recurse => true,
    }
  }

  if $manage_limits_file {
    file { $limits_file:
      ensure  => file,
      owner   => $limits_file_owner,
      group   => $limits_file_group,
      mode    => $limits_file_mode,
      content => template("limits/${limits_template}.erb"),
    }
  }

  if $entries !~ Undef {
    each($entries) | $e_name, $e_params | {
      limits::limits { $e_name:
        * => $e_params,
      }
    }
  }
}
