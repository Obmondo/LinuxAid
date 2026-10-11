#!/bin/bash
# THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
#
# Expands the unit globs in monitor::system::service::down::blacklist_glob into
# literal threshold::monitor::system::service::down::blacklist metrics for the
# node_exporter textfile collector, so failed units matching a glob don't alert.
#
# Settings come from /etc/default/obmondo-service-down-blacklist-glob:
#   TARGET_FILE  textfile to write
#   CERTNAME     value of the certname label
#   GLOBS        array of systemctl unit globs, e.g. ('vsts.agent.*')
#   EXCLUDE      array of unit names already blacklisted by puppet; skipped here
#                because node_exporter fails the scrape on duplicate series

set -eo pipefail

. /etc/default/obmondo-service-down-blacklist-glob

metric='threshold::monitor::system::service::down::blacklist'
tmp_file="${TARGET_FILE}.$$.tmp"
trap 'rm -f "$tmp_file"' EXIT

units=$(systemctl list-units --all --type=service --plain --no-legend --no-pager -- "${GLOBS[@]}" \
          | awk '{ for (i = 1; i <= NF; i++) if ($i ~ /\.service$/) { print $i; break } }' \
          | sort -u)

{
  echo '# THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.'
  echo "# HELP ${metric} The threshold for monitor::system::service::down::blacklist alert"
  echo "# TYPE ${metric} counter"
  while IFS= read -r unit; do
    [ -n "$unit" ] || continue
    for excluded in "${EXCLUDE[@]}"; do
      [ "$unit" = "$excluded" ] && continue 2
    done
    # Prometheus text format needs backslashes and double quotes escaped
    name=${unit//\\/\\\\}
    name=${name//\"/\\\"}
    echo "${metric}{certname=\"${CERTNAME}\", name=\"${name}\"} 1"
  done <<< "$units"
} > "$tmp_file"

chmod 0644 "$tmp_file"
mv -f "$tmp_file" "$TARGET_FILE"
trap - EXIT
