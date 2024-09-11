#!/bin/bash
set -o errexit
set -o nounset

[[ ! -f $MAILLOG ]] && (echo 'Log file missing'; exit 1)
/usr/bin/tail --quiet -F $MAILLOG | /usr/local/sbin/postfix-stats.py --daemon --port $STATS_DAEMON_PORT
