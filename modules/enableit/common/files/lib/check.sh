#!/bin/bash

set -o nounset
set -o errexit

declare -rix EXIT_OK=0
declare -rix EXIT_WARNING=1
declare -rix EXIT_CRITICAL=2
declare -rix EXIT_UNKNOWN=3
declare -rix EXIT_WRONG_ARGS=4

function exit.warning {
    /usr/bin/logger --tag "$0[$$]" --priority syslog.err "$1"
    echo -e "$1"
    exit $EXIT_WARNING
}

function exit.critical {
    /usr/bin/logger --tag "$0[$$]" --priority syslog.crit "$1"
    echo -e "$1"
    exit $EXIT_CRITICAL
}

function exit.ok {
    /usr/bin/logger --tag "$0[$$]" --priority syslog.debug "$1"
    echo -e "$1"
    exit $EXIT_OK
}
