#!/bin/bash
#
# action: make the DISPLAY environment variable include the hostname
#
# See
# http://lists.cendio.se/pipermail/thinlinc-technical/2015-December/005748.html
HOSTNAME=$(hostname)

if [ "${DISPLAY:0:1}" == ":" ]; then
  export DISPLAY=${HOSTNAME}${DISPLAY}
fi
