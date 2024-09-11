#!/bin/bash
# Check rsnapshot log file for errors
#
# Usage:
#   ./check_rsnapshot.sh LOGDIR SOURCE DESTINATION
#
# Example:
#   ./check_rsnapshot.sh /var/log/rsnapshot jarjar.enableit.dk /data/backup/jarjar
#
# shellcheck disable=SC2155


set -o nounset
set -o errexit

. /opt/obmondo/lib/common.sh
. /opt/obmondo/lib/check.sh

declare -r LOGPATH=$1
declare -r SOURCE=$2
declare -r TARGET_BASE=$3
declare -r TARGET="${TARGET_BASE}/${SOURCE}"

declare -r LOG_FILE="${LOGPATH}/${SOURCE}.log"

if [ ! -f "${LOG_FILE}" ]; then
    exit.critical "rsnapshot log file '${LOG_FILE}' doesn't exist"
fi

# We only want to check the log messages from today; we don't care about
# previous errors.
declare -r DATE=$(date -Idate)

set +o errexit
ERR_MESSAGE=$(grep -E --only-matching "^\[${DATE}.*? ERROR:.*$" "${LOG_FILE}")
declare -i EXIT_CODE=$?
set -o errexit

if [[ $EXIT_CODE == 0 ]]; then
    exit.critical "error in rsnapshot log file for ${SOURCE}:\n${ERR_MESSAGE}"
fi

# Check that target dir for today or yesterday has been modified today or
# yesterday.  That does sound weird, but we don't want to produce an error if
# the backup hasn't run yet today, which is why we check yesterday was well.
LAST_MODIFIED_DATES=$(stat --format='%y' "${TARGET}/daily.0" "${TARGET}/daily.1" | awk '{print $1;}')
GREP_RE="${DATE}|$(date -Idate --date=yesterday)"

set +o errexit
ERR_MESSAGE=$(grep -E --only-matching "${GREP_RE}" <<< "$LAST_MODIFIED_DATES")
declare -i EXIT_CODE=$?
set -o errexit

if [[ $EXIT_CODE != 0 ]]; then
    exit.critical "rsnapshot backup for ${SOURCE} last ran successfully at $(cut --delimiter=' ' --fields=1 <<< "$LAST_MODIFIED_DATES")"
fi

exit.ok "rsnapshot backup for ${SOURCE} is fine"
