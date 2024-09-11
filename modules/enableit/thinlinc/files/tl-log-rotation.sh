#!/bin/bash
# -*- mode: shell-script; coding: utf-8 -*-

# action: Log rotation
#

set -euo pipefail

THINLIC_DIR="/var/opt/thinlinc"
THINLIC_SESSION_DIR="$THINLIC_DIR/sessions"
THINLIC_SESSION_LOG_DIR="/var/log/thinlinc/sessions"

test -d "$THINLIC_SESSION_LOG_DIR/$USERNAME" || mkdir -p "$THINLIC_SESSION_LOG_DIR/$USERNAME"

SESSIONS_ENDED_DIRS=$(find "$THINLIC_SESSION_DIR/$USERNAME" -path '*.ended*' -name xinit.log)

for XINIT_LOG in "${SESSIONS_ENDED_DIRS[@]}"; do
  # basename $(dirname /var/opt/thinlinc/sessions/${USERNAME}/10.1579250017.ended/xinit.log) |cut -d '.' -f2
  # 1579250017
  DIRNAME=$(dirname "$XINIT_LOG")
  TIMESTAMP=$(basename "$DIRNAME" | cut -d '.' -f2)
  FILENAME="xinit-${TIMESTAMP}.log"

  # copy xinit.log of thinlinc session which is ended
  # --update copy only when the SOURCE file is newer than the destination file or when the destination file is missing
  # --preserver preserve the specified attributes (default: mode,ownership,timestamps), if possible additional attributes: context, links, xattr, all

  cp --update --preserve "$XINIT_LOG" "$THINLIC_SESSION_LOG_DIR/$USERNAME/$FILENAME"
done
