#!/bin/bash

if [ "x$WILDFLY_HOME" = "x" ]; then
    WILDFLY_HOME="/opt/wildfly"
fi

mode="$1"
shift

if [[ "$mode" == "domain" ]]; then
    exec $WILDFLY_HOME/bin/domain.sh -c "$@"
else
    exec $WILDFLY_HOME/bin/standalone.sh -c "$@"
fi
