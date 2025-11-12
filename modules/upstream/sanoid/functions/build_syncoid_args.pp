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

  $args = []

  # Add identifier if specified
  if $options['identifier'] {
    $args << "--identifier=${options['identifier']}"
  }

  # Add boolean flags
  if $options['recursive'] {
    $args << '--recursive'
  }

  if $options['skip_parent'] {
    $args << '--skip-parent'
  }

  # Add compression method
  if $options['compress'] {
    $args << "--compress=${options['compress']}"
  }

  # Add bandwidth limits
  if $options['source_bwlimit'] {
    $args << "--source-bwlimit=${options['source_bwlimit']}"
  }

  if $options['target_bwlimit'] {
    $args << "--target-bwlimit=${options['target_bwlimit']}"
  }

  # Add advanced options
  if $options['no_command_checks'] {
    $args << '--no-command-checks'
  }

  if $options['no_stream'] {
    $args << '--no-stream'
  }

  if $options['no_sync_snap'] {
    $args << '--no-sync-snap'
  }

  if $options['keep_sync_snap'] {
    $args << '--keep-sync-snap'
  }

  if $options['create_bookmark'] {
    $args << '--create-bookmark'
  }

  if $options['use_hold'] {
    $args << '--use-hold'
  }

  if $options['preserve_recordsize'] {
    $args << '--preserve-recordsize'
  }

  if $options['preserve_properties'] {
    $args << '--preserve-properties'
  }

  if $options['delete_target_snapshots'] {
    $args << '--delete-target-snapshots'
  }

  if $options['no_clone_rollback'] {
    $args << '--no-clone-rollback'
  }

  if $options['no_rollback'] {
    $args << '--no-rollback'
  }

  # Add exclude pattern (deprecated, kept for compatibility)
  if $options['exclude'] {
    $args << "--exclude=${options['exclude']}"
  }

  # Add exclude-datasets (can be string or array)
  if $options['exclude_datasets'] {
    if $options['exclude_datasets'] =~ String {
      $args << "--exclude-datasets=${options['exclude_datasets']}"
    } else {
      $options['exclude_datasets'].each |$pattern| {
        $args << "--exclude-datasets=${pattern}"
      }
    }
  }

  # Add exclude-snaps (can be string or array)
  if $options['exclude_snaps'] {
    if $options['exclude_snaps'] =~ String {
      $args << "--exclude-snaps=${options['exclude_snaps']}"
    } else {
      $options['exclude_snaps'].each |$pattern| {
        $args << "--exclude-snaps=${pattern}"
      }
    }
  }

  # Add include-snaps (can be string or array)
  if $options['include_snaps'] {
    if $options['include_snaps'] =~ String {
      $args << "--include-snaps=${options['include_snaps']}"
    } else {
      $options['include_snaps'].each |$pattern| {
        $args << "--include-snaps=${pattern}"
      }
    }
  }

  # Add no-resume flag
  if $options['no_resume'] {
    $args << '--no-resume'
  }

  # Add force-delete flag
  if $options['force_delete'] {
    $args << '--force-delete'
  }

  # Add no-clone-handling flag
  if $options['no_clone_handling'] {
    $args << '--no-clone-handling'
  }

  # Add dumpsnaps flag
  if $options['dumpsnaps'] {
    $args << '--dumpsnaps'
  }

  # Add no-privilege-elevation flag
  if $options['no_privilege_elevation'] {
    $args << '--no-privilege-elevation'
  }

  # Add SSH options
  if $options['sshport'] {
    $args << "--sshport=${options['sshport']}"
  }

  if $options['sshcipher'] {
    $args << "--sshcipher=${options['sshcipher']}"
  }

  # Add sshoption (can be string or array)
  if $options['sshoption'] {
    if $options['sshoption'] =~ String {
      $args << "--sshoption=${options['sshoption']}"
    } else {
      $options['sshoption'].each |$opt| {
        $args << "--sshoption=${opt}"
      }
    }
  }

  if $options['sshkey'] {
    $args << "--sshkey=${options['sshkey']}"
  }

  # Join all arguments with spaces
  $args.join(' ')
}
