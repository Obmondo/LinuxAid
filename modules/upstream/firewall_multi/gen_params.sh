#!/usr/bin/env bash

if [ "$(uname -s)" == "Darwin" ] ; then
  if [ ! -x /usr/local/bin/gsed ] ; then
    echo "On Mac OS X you need to install gnu-sed:"
    echo "$ brew install gnu-sed"
    exit 1
  fi

  shopt -s expand_aliases
  alias sed='/usr/local/bin/gsed'
fi

path_to_firewall=../puppetlabs-firewall  # Path to wherever the firewall module
                                         # is checked out.

_firewall_lib() {
  cat "$path_to_firewall"'/lib/puppet/type/firewall.rb'
}

usage() {
  echo "Usage: bash $0 > manifests/init.pp"
  exit 1
}

[ "$1" == -h ] && usage

header() {
  cat <<'EOF'
# @summary A defined type wrapper for spawning
#   [puppetlabs/firewall](https://github.com/puppetlabs/puppetlabs-firewall)
#   resources for arrays of certain inputs.
#
# @param [Array] source An array of source IPs or CIDRs.
# @param [Array] destination An array of destination IPs or CIDRs.
# @param [Array] proto An array of proto's.
# @param [Array] icmp An array of ICMP types.
#
define firewall_multi (
  $ensure                      = undef,
EOF
}

middle() {
  cat <<'EOF'
) {

  $firewalls = firewall_multi(
    {
      $name => {
        ensure                       =>  $ensure,
EOF
}

footer() {
  cat <<'EOF'
      }
    }
  )

  create_resources(firewall, $firewalls)
}
EOF
}

transform() {
  local mode="$1"
  local indent

  case "$mode" in
    1) indent="  "
      ;;
    2) indent="        "
      ;;
  esac

  _firewall_lib |
  awk -v mode="$mode" '
    BEGIN {
      trim = "^[ \t]+|[ \t]+$"
    }

    /^  attributes: {/ {
      flag=1
      next
    }

    /^  }/ {
      flag=0
    }

    /^    [^ }]/ {
      if (!flag) next
      if (/^  *name:/) next
      if (/^  *ensure:/) next

      split($0, arr, ":")
      gsub(trim, "", arr[1])

      if (mode == "1") {
        print "$" arr[1] " = undef,"
      } else if (mode == "2") {
        print arr[1] " => $" arr[1] ","
      }
    }
  ' |
  sort |
  column -t |
  sed '
    s/^/'"$indent"'/
    s/ = /=/
  '
}

main() {
  header
  transform "1"
  middle
  transform "2"
  footer
}

if [ "$0" == "${BASH_SOURCE[0]}" ] ; then
  main
fi

# vim: set ft=sh:
