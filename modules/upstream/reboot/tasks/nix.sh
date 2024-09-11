#!/usr/bin/env bash
export PATH=$PATH:/usr/sbin:/sbin
set -e

if [[ $EUID > 0 ]]
then
  echo "{\"Error\": \"Run as root or sudo; use the '--user root' option to run it as root user or the '--run-as root --sudo-password' options to run it with sudo in Bolt tasks or plans.\"}"
  exit 1
fi

if [ -n "$PT_timeout" ]; then
  timeout=$PT_timeout
else
  timeout=3
fi

if [ -n "$PT_message" ]; then
  message=$PT_message
fi

if [ -n "$PT_shutdown_only" ]; then
  shutdown_only=$PT_shutdown_only
fi

# Force a minimum timeout of 3 second to allow the task response to be delivered.
if [ $timeout -lt 3 ]; then
  timeout=3
fi

if [[ `uname -s` == 'SunOS' ]]; then
  init_level=6
  if [ "$shutdown_only" = true ]; then
    init_level=5
  fi
  shutdown -y -i $init_level -g $timeout $message </dev/null >/dev/null 2>&1 &
else
  # Linux only supports timeout in minutes. Handle the remainder with sleep.
  timeout_min=$(($timeout/60))
  timeout_sec=$(($timeout%60))
  # When doing a shutdown -r +0 , the message is never displayed to the end user.
  # Instead when timeout_min == 0 and we're using sleep to create our timeout
  # simply use `wall` to broadcast our message.
  if [ $timeout_min -lt 1 ]; then
    nohup bash -c "wall \"$message\"" </dev/null >/dev/null 2>&1 &
  fi
  reboot_flag="-r"
  if [ "$shutdown_only" = true ]; then
    reboot_flag="-P"
  fi
  nohup bash -c "sleep $timeout_sec; shutdown $reboot_flag +$timeout_min $message" </dev/null >/dev/null 2>&1 &
  disown
fi

# There are some weird race conditions that might make detached jobs still die
# when this shell exits. The sync (which otherwise shouldn't do much) seems to
# eliminate them.
sync

echo "{\"status\":\"queued\",\"timeout\":$timeout}"
