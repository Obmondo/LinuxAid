#!/bin/bash

### BEGIN INIT INFO
# Provides:          delayed_job
# Required-Start:    $local_fs $network $named $time $syslog
# Required-Stop:     $local_fs $network $named $time $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       Elvium\ custom\ delayed\ job\ daemon\ to\ run\ job\ in\ background\,\ by\ default\ we\ run\ 4\ background\ process.
### END INIT INFO


test -f /bin/delayed_job || exit 0

PIDFILE=/var/run/delayed_job.pid

# shellcheck disable=SC1091
. /lib/lsb/init-functions

export RBENV_ROOT=/home/elvium/.rbenv
export RBENV_VERSION=2.3.1
export RAILS_ENV=production
export RBENV_HOOK_PATH=/home/elvium/.rbenv/rbenv.d:/usr/local/etc/rbenv.d:/etc/rbenv.d:/usr/lib/rbenv/hooks
export PATH=/home/elvium/.rbenv/versions/2.3.1/bin:/home/elvium/.rbenv/libexec:/home/elvium/.rbenv/plugins/ruby-build/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
export DELAYED_JOB_USER=root
export DELAYED_JOB_DIR=/home/elvium/elvium/current
export DELAYED_JOB_BIN=rbenv
export DELAYED_JOB_OPTS='exec bundle exec /home/elvium/elvium/current/bin/delayed_job -n 4'

start_job ()
{
  # shellcheck disable=SC2086
  start-stop-daemon --start --quiet --chuid $DELAYED_JOB_USER --chdir $DELAYED_JOB_DIR --pidfile $PIDFILE --make-pidfile --background --name delayed_job --startas $DELAYED_JOB_BIN -- $LSBNAMES $DELAYED_JOB_OPTS
  log_end_msg $?
}

stop_job ()
{
  start-stop-daemon --stop --quiet --pidfile $PIDFILE
  STATUS=$?
  if [ $STATUS == 0 ]; then
    rm -r $PIDFILE
  fi
  log_end_msg $STATUS
}

case "$1" in
start)
  log_daemon_msg "Starting Delayed Job" "delayed_job"
  start_job
  ;;
stop)
  log_daemon_msg "Stopping Delayed Job" "delayed_job"
  stop_job
  ;;
restart)
  log_daemon_msg "Restarting Delayed Job" "delayed_job"
  stop_job
  start_job
          ;;
status)
  log_action_begin_msg "Checking Delayed Job"
  if pidofproc -p "$PIDFILE" node >/dev/null; then
    if [[ -f /home/elvium/elvium/shared/tmp/pids/delayed_job.0.pid && -f /home/elvium/elvium/shared/tmp/pids/delayed_job.1.pid && -f /home/elvium/elvium/shared/tmp/pids/delayed_job.2.pid && -f /home/elvium/elvium/shared/tmp/pids/delayed_job.3.pid ]]; then
      log_action_end_msg 0 "running"
      exit 0
    else
      log_action_end_msg 0 "No PID files under /home/elvium/elvium/shared/tmp/pids directory, Exiting"
      exit 3
    fi
  else
    if [ -e "$PIDFILE" ]; then
      log_action_msg 1 "failed to start"
      exit 1
    else
      log_action_end_msg 0 "not running"
      exit 3
    fi
  fi
  ;;
*)
  log_action_msg "Usage: /etc/init.d/delayed_job {start|stop|status|restart}"
  exit 2
  ;;
esac

exit 0
