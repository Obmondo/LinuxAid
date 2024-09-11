#!/bin/bash
# Wrapper around curl to avoid printing anything to stdout/stderr for 2xx
# responses. Output from succesfull requests are instead printed using logger.
#
# shellcheck disable=SC2155

. /opt/obmondo/lib/common.sh

# Get the total number of arguments
declare -ri ARG_COUNT=${#@}
# curl options are any arguments except the last
CURL_OPTS=''

for i in $(seq 1 $((ARG_COUNT -1))); do
    n="${*:i:1}"
    CURL_OPTS="$CURL_OPTS $n"
done

# The URL is the last argument -- we only support one URL. We could support more
# if we wanted to, by looking for a leading `-` in the argument list.
CURL_URL="${*:ARG_COUNT}"

# Temporary file for curl response output
declare -r OUTPUT_FILE=$(mktemp)

HTTP_CODE=$(eval curl                      \
                "$CURL_OPTS"               \
                --write-out "%{http_code}" \
                --output "${OUTPUT_FILE}"  \
                --silent                   \
                --fail                     \
                "$CURL_URL")
declare -ri CURL_EXIT=$?

if [[ ! $HTTP_CODE =~ 2[0-9]{2} ]]; then
    cat "$OUTPUT_FILE"
    rm $OUTPUT_FILE
    exit $CURL_EXIT
fi

/usr/bin/logger -t "$0[$$]" -p syslog.info -f "$OUTPUT_FILE"
rm $OUTPUT_FILE
