# @summary Build syncoid command line arguments from options hash
#
# This function takes a Sanoid::Syncoid::Options hash and converts it
# into a string of command-line arguments for the syncoid command.
#
# @param options
#   Hash of syncoid options
#
# @return String
#   Space-separated command-line arguments
#
function sanoid::build_syncoid_args(
  Sanoid::Syncoid::Options $options
) >> String {

  # Build array with all possible arguments (including undef)
  $all_args = [
    $options['identifier'] ? {
      undef   => undef,
      default => "--identifier=${options['identifier']}",
    },
    $options['recursive'] ? {
      true    => '--recursive',
      default => undef,
    },
    $options['skip_parent'] ? {
      true    => '--skip-parent',
      default => undef,
    },
    $options['compress'] ? {
      undef   => undef,
      default => "--compress=${options['compress']}",
    },
    $options['source_bwlimit'] ? {
      undef   => undef,
      default => "--source-bwlimit=${options['source_bwlimit']}",
    },
    $options['target_bwlimit'] ? {
      undef   => undef,
      default => "--target-bwlimit=${options['target_bwlimit']}",
    },
    $options['no_command_checks'] ? {
      true    => '--no-command-checks',
      default => undef,
    },
    $options['no_stream'] ? {
      true    => '--no-stream',
      default => undef,
    },
    $options['no_sync_snap'] ? {
      true    => '--no-sync-snap',
      default => undef,
    },
    $options['keep_sync_snap'] ? {
      true    => '--keep-sync-snap',
      default => undef,
    },
    $options['create_bookmark'] ? {
      true    => '--create-bookmark',
      default => undef,
    },
    $options['use_hold'] ? {
      true    => '--use-hold',
      default => undef,
    },
    $options['preserve_recordsize'] ? {
      true    => '--preserve-recordsize',
      default => undef,
    },
    $options['preserve_properties'] ? {
      true    => '--preserve-properties',
      default => undef,
    },
    $options['delete_target_snapshots'] ? {
      true    => '--delete-target-snapshots',
      default => undef,
    },
    $options['no_clone_rollback'] ? {
      true    => '--no-clone-rollback',
      default => undef,
    },
    $options['no_rollback'] ? {
      true    => '--no-rollback',
      default => undef,
    },
    $options['exclude'] ? {
      undef   => undef,
      default => "--exclude=${options['exclude']}",
    },
    $options['no_resume'] ? {
      true    => '--no-resume',
      default => undef,
    },
    $options['force_delete'] ? {
      true    => '--force-delete',
      default => undef,
    },
    $options['no_clone_handling'] ? {
      true    => '--no-clone-handling',
      default => undef,
    },
    $options['dumpsnaps'] ? {
      true    => '--dumpsnaps',
      default => undef,
    },
    $options['no_privilege_elevation'] ? {
      true    => '--no-privilege-elevation',
      default => undef,
    },
    $options['sshport'] ? {
      undef   => undef,
      default => "--sshport=${options['sshport']}",
    },
    $options['sshcipher'] ? {
      undef   => undef,
      default => "--sshcipher=${options['sshcipher']}",
    },
    $options['sshkey'] ? {
      undef   => undef,
      default => "--sshkey=${options['sshkey']}",
    },
  ]

  # Handle array options that can appear multiple times
  $exclude_datasets_args = $options['exclude_datasets'] ? {
    undef   => [],
    String  => ["--exclude-datasets=${options['exclude_datasets']}"],
    Array   => $options['exclude_datasets'].map |$pattern| { "--exclude-datasets=${pattern}" },
    default => [],
  }

  $exclude_snaps_args = $options['exclude_snaps'] ? {
    undef   => [],
    String  => ["--exclude-snaps=${options['exclude_snaps']}"],
    Array   => $options['exclude_snaps'].map |$pattern| { "--exclude-snaps=${pattern}" },
    default => [],
  }

  $include_snaps_args = $options['include_snaps'] ? {
    undef   => [],
    String  => ["--include-snaps=${options['include_snaps']}"],
    Array   => $options['include_snaps'].map |$pattern| { "--include-snaps=${pattern}" },
    default => [],
  }

  $sshoption_args = $options['sshoption'] ? {
    undef   => [],
    String  => ["--sshoption=${options['sshoption']}"],
    Array   => $options['sshoption'].map |$opt| { "--sshoption=${opt}" },
    default => [],
  }

  # Combine all arguments and filter out undef values
  $combined_args = $all_args + $exclude_datasets_args + $exclude_snaps_args + $include_snaps_args + $sshoption_args

  $final_args = $combined_args.filter |$arg| { $arg =~ NotUndef }

  # Join all arguments with spaces
  $final_args.join(' ')
}
