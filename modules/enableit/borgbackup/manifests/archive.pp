#
# This class creates an archive in a repo
# 
# Parameters:
#
# $reponame,
#   The name of the repo to add the archive
#   defaults to $facts['networking']['fqdn'], the default repo created
#   by including borgbackup without parameters
# $archive_name
#   The name of the archive.
#   Defaults to $title
# $pre_commands
#   Array of commands to run before the backup run
#   Defaults to []
# $post_commands
#   Array of commands to run after the backup run
#   Defaults to []
# $create_compression
#   the compression to use for create. 
#   Set to '' if no compresseion should be applied.
#   Defaults to 'lz4'
# $create_filter
#   Filter items to display for create commnd. 
#   Set to '' if no filter should be applied.
#   Defaults to 'AME' (show Added, Modified and Error files)
# $create_options
#   Array of additional options to add to the create command.
#   Each item will be prefixed with '--' (means use long name !)
#   Defaults to ['verbose', 'list', 'stats', 'show-rc', 'exclude-caches']
# $create_excludes
#   Array of excludes
#   Defaults to []
#   needs to be [] if stdin_cmd is used.
# $create_includes
#   Array of file to include
#   Defaults to []
#   needs to be [] if stdin_cmd is used.
# $stdin_cmd
#   command which is executed, stdout is used as
#   input to backup. defaults to ''
#   do not use together with $create_excludes and $create_includes
# $do_prune
#   if true, prune will be run after the create command.
#   Defaults to true
# $prune_options
#   Array of additional options to add to the prune command.
#   Each item will be prefixed with '--' (means use long name !)
#   Defaults to ['list', 'show-rc']
# $keep_last
#   number of last archives to keep
#   Set to '' if this option should not be added
#   Defaults to ''
# $keep_hourly
#   number of hourly archives to keep
#   Set to '' if this option should not be added
#   Defaults to ''
# $keep_daily
#   number of daily archives to keep
#   Set to '' if this option should not be added
#   Defaults to 7
# $keep_weekly
#   number of weekly archives to keep
#   Set to '' if this option should not be added
#   Defaults to 4
# $keep_monthly
#   number of monthly archives to keep
#   Set to '' if this option should not be added
#   Defaults to 6
# $keep_yearly
#   number of yearly archives to keep
#   Set to '' if this option should not be added
#   Defaults to ''
#
define borgbackup::archive (
  String                   $reponame           = $facts['networking']['fqdn'],
  String                   $archive_name       = $title,
  Array                    $pre_commands       = [],
  Array                    $post_commands      = [],
  String                   $create_compression = 'lz4',
  String                   $create_filter      = 'AME',
  Array                    $create_options     = ['verbose', 'list', 'stats', 'show-rc', 'exclude-caches'],
  Array                    $create_excludes    = [],
  Array                    $create_includes    = [],
  String                   $stdin_cmd          = '',
  Boolean                  $do_prune           = true,
  Array                    $prune_options      = ['list', 'show-rc'],
  Variant[String, Integer] $keep_last          = '',
  Variant[String, Integer] $keep_hourly        = '',
  Variant[String, Integer] $keep_daily         = 7,
  Variant[String, Integer] $keep_weekly        = 4,
  Variant[String, Integer] $keep_monthly       = 6,
  Variant[String, Integer] $keep_yearly        = '',
){

  if ($stdin_cmd != '' and $create_includes != []) or ($stdin_cmd != '' and $create_excludes != []) {
    fail('borgbackup::archive $stdin_cmd cannot be used together with $create_includes or $create_exclude')
  }

  include ::borgbackup

  $configdir = $::borgbackup::configdir

  concat::fragment{ "borgbackup::archive ${reponame} create ${archive_name}":
    target  => "${configdir}/repo_${reponame}.sh",
    content => template('borgbackup/archive_create.erb'),
    order   => "20-${title}",
  }

  if $do_prune {
    concat::fragment{ "borgbackup::archive ${reponame} prune ${archive_name}":
      target  => "${configdir}/repo_${reponame}.sh",
      content => template('borgbackup/archive_prune.erb'),
      order   => "70-${title}",
    }
  }
}
