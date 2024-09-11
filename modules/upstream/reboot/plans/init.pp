# Reboots targets and waits for them to be available again.
#
# @param targets Targets to reboot.
# @param message Message to log with the reboot (for platforms that support it).
# @param reboot_delay How long (in seconds) to wait before rebooting. Defaults to 1.
# @param disconnect_wait How long (in seconds) to wait before checking whether the server has rebooted. Defaults to 10.
# @param reconnect_timeout How long (in seconds) to attempt to reconnect before giving up. Defaults to 180.
# @param retry_interval How long (in seconds) to wait between retries. Defaults to 1.
# @param fail_plan_on_errors Raise an error if any targets do not successfully reboot. Defaults to true.
plan reboot (
  TargetSpec $targets,
  Optional[String] $message = undef,
  Integer[1] $reboot_delay = 1,
  Integer[0] $disconnect_wait = 10,
  Integer[0] $reconnect_timeout = 180,
  Integer[0] $retry_interval = 1,
  Boolean    $fail_plan_on_errors = true,
) {
  $target_objects = get_targets($targets)

  # Short-circuit the plan if the TargetSpec given was empty
  if $target_objects.empty { return ResultSet.new([]) }

  # Get last boot time
  $begin_boot_time_results = without_default_logging() || {
    run_task('reboot::last_boot_time', $target_objects)
  }

  # Reboot; catch errors here because the connection may get cut out from underneath
  $reboot_result = run_task('reboot', $targets, timeout => $reboot_delay, message => $message)

  # Wait long enough for all targets to trigger reboot, plus disconnect_wait to allow for shutdown time.
  $timeouts = $reboot_result.map |$result| { $result['timeout'] }
  $wait = max($timeouts)
  reboot::sleep($wait+$disconnect_wait)

  $start_time = Timestamp()
  # Wait for reboot in a loop
  ## Check if we can connect; if we can retrieve last boot time.
  ## Mark finished for targets with a new last boot time.
  ## If we still have targets check for timeout, sleep if not done.
  $wait_results = without_default_logging() || {
    $reconnect_timeout.reduce({'pending' => $target_objects, 'ok' => []}) |$memo, $_| {
      if ($memo['pending'].empty() or $memo['timed_out']) {
        break()
      }

      $plural = if $memo['pending'].size() > 1 { 's' }
      out::message("Waiting: ${$memo['pending'].size()} target${plural} rebooting")
      $current_boot_time_results = run_task('reboot::last_boot_time', $memo['pending'], _catch_errors => true)

      # Compare boot times
      $failed_results = $current_boot_time_results.filter |$current_boot_time_res| {
        # If this one errored, need to check it again
        if !$current_boot_time_res.ok() {
          true
        }
        else {
          # If this succeeded, then we have a boot time, compare it against the begin_boot_time
          $target_name = $current_boot_time_res.target().name()
          $begin_boot_time_res = $begin_boot_time_results.find($target_name)

          # If the boot times are the same, then we need to check it again
          $current_boot_time_res.value() == $begin_boot_time_res.value()
        }
      }

      # $failed_results is an array of results, turn it into a ResultSet so we can
      # extract the targets from it
      $failed_targets = ResultSet($failed_results).targets()
      $ok_targets = $memo['pending'] - $failed_targets

      # Calculate whether or not timeout has been reached
      $elapsed_time_sec = Integer(Timestamp() - $start_time)
      $timed_out = $elapsed_time_sec >= $reconnect_timeout

      if !$failed_targets.empty() and !$timed_out {
        # sleep for a small time before trying again
        reboot::sleep($retry_interval)

        # wait for all targets to be available again
        $remaining_time = $reconnect_timeout - $elapsed_time_sec
        wait_until_available($failed_targets, wait_time => $remaining_time, retry_interval => $retry_interval)
      }

      # Build and return the memo for this iteration
      ({
        'pending'   => $failed_targets,
        'ok'        => $memo['ok'] + $ok_targets,
        'timed_out' => $timed_out,
      })
    }
  }

  $err = {
    msg  => 'Target failed to reboot before wait timeout.',
    kind => 'bolt/reboot-timeout',
  }

  $error_set = $wait_results['pending'].map |$target| {
    Result.new($target, {
      _output => 'failed to reboot',
      _error  => $err,
    })
  }
  $ok_set = $wait_results['ok'].map |$target| {
    Result.new($target, {
      _output => 'rebooted',
    })
  }

  $result_set = ResultSet.new($ok_set + $error_set)

  if ($fail_plan_on_errors and !$result_set.ok) {
    fail_plan('One or more targets failed to reboot within the allowed wait time',
      'bolt/reboot-failed', {
        action         => 'plan/reboot',
        result_set     => $result_set,
        failed_targets => $result_set.error_set.targets, # legacy / deprecated
    })
  }
  else {
    return($result_set)
  }
}
