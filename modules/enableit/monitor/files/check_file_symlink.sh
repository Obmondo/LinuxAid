#!/bin/bash

set +eu

function check_symlink {
    if [ ! -L "/var/lib/lxc/$1" ]; then
        echo "CRITICAL: $1 is not a symlink file, please check"
        exit 2
    fi
}

for i in `lxc-ls`; do
    check_symlink $i
done

echo "OK: no symlink files present"
