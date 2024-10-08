#!/bin/sh
# shellcheck disable=SC2034,SC2034,SC2059,SC1090,SC2154,SC2154,SC2154,SC2154,SC2154,SC2154,SC2034,SC2086,SC2046,SC2086,SC1001,SC2086,SC1001,SC2154,SC2154,SC2154,SC1001,SC2059,SC2059,SC1001,SC1001,SC2059,SC2059,SC1001,SC1001,SC2059,SC2059,SC2154,SC2154,SC2154,SC2154,SC2154,SC2002,SC2154,SC2002,SC2154,SC2154,SC2002,SC2162,SC2154,SC2002,SC2162,SC2154,SC2002,SC2162,SC2002,SC2162,SC2002,SC2162,SC2002,SC2162,SC2154,SC2154,SC2002,SC2154,SC2154,SC2002,SC2059,SC2154,SC2154,SC2059,SC2059,SC2154,SC2059,SC2154,SC2154,SC2086
###################################################################
# Postwhite - Automatic Postcreen Whitelist / Blacklist Generator #
# https://github.com/stevejenkins/postwhite                       #
###################################################################

# By Steve Jenkins (https://www.stevejenkins.com/)

version="3.1"
lastupdated="30 April 2017"

# Usage: 1) Place entire /postwhite directory in /usr/local/bin
#  2) Move postwhite.conf to /etc
#  3) Run ./postwhite [config-file]
# Optional config file passed via command line overrides the default config file location.

# Requires SPF-Tools (https://github.com/jsarenik/spf-tools)
# Please update your copy of spf-tools whenever you update Postwhite

# Thanks to Mike Miller (mmiller@mgm51.com) for gwhitelist.sh script
# Thanks to Jan Sarenik for SPF-Tools
# Thanks to Jose Borges Ferreira for IPv4 normalization help
# Thanks to Ricardo Iván Vieitez Parra for improved error reporting, normalization, conf file improvements,
#           and removal of bash-isms so that script is usable on more systems
# Thanks to Steve Cook for Yahoo! IP scraping help

# USER-DEFINABLE OPTIONS AND CUSTOM HOSTS STORED IN /etc/postwhite.conf
# CONFIGURATION FILE CAN ALSO BE PASSED FROM COMMAND LINE

# NO NEED TO EDIT PAST THIS LINE

#################################################################

# DEFAULT HOSTS
# CUSTOM HOSTS CAN BE ADDED IN /etc/postwhite.conf

# Hosts to query
webmail_hosts="aol.com google.com microsoft.com outlook.com hotmail.com gmx.com icloud.com mail.com inbox.com zoho.com fastmail.com"

social_hosts="facebook.com facebookmail.com twitter.com pinterest.com instagram.com tumblr.com reddit.com linkedin.com"

commerce_hosts="craigslist.org amazon.com ebay.com paypal.com"

bulk_hosts="sendgrid.com sendgrid.net mailchimp.com exacttarget.com cust-spf.exacttarget.com constantcontact.com icontact.com mailgun.com fishbowl.com fbmta.com mailjet.com sparkpost.com sparkpostmail.com"

misc_hosts="zendesk.com github.com"

permit_line_v4="%s\tpermit\n"
reject_line_v4="%s\treject\n"

permit_line_v6="${permit_line_v4}"
reject_line_v6="${reject_line_v4}"

# Abort script on error (FYI: enabling will cause script to exit silently if mailer has no valid results)
set -e

printf "Starting Postwhite v$version ($lastupdated)\n"

# Check for passed config file
if [ -n "$1" ]; then
  config_file="$1"
else
  config_file="/etc/postwhite.conf"
fi

# Read config file options
if [ -s $config_file ] ; then
  printf "\nReading options from %s...\n" "$config_file"
  . "${config_file}"
else
  >&2 printf "%s: Can't find %s. Exiting.\n" "$0" "$config_file"
  exit 1
fi

# Create temporary files
printf "\nCreating temporary files...\n"
tmpBase=$(basename "$0")

if [ x"$enable_blacklist" = x"yes" ]; then
  tmpPrefix="tmp blktmp"
else
  tmpPrefix="tmp"
fi

for p in $tmpPrefix; do
  for i in 1 2 3 4 5; do
    t="$(mktemp -q /tmp/"${tmpBase}".XXXXXX)"
    if [ $? -ne 0 ]; then
      >&2 printf "%s: Can't create temp files, exiting...\n" "$0"
      cleanup
      exit 1
    fi
    eval ${p}${i}="$t"
  done
done

# Create IPv4 normalize function
ip2int() {
  for i in 1 2 3 4 5; do
    eval ip2int_${i}="$(echo "$1" | cut -s -d. -f$i)"
  done
  ip2int_valid_range="$((ip2int_1 | ip2int_2 | ip2int_3 | ip2int_4))"
  [ -z "$ip2int_5" ] && [ -n "$ip2int_1" ] && [ -n "$ip2int_2" ] && [ -n "$ip2int_3" ] && [ -n "$ip2int_4" ] && [ "$ip2int_valid_range" -ge 0 ] && [ "$ip2int_valid_range" -le 255 ] &&
    printf "%d" "$(((((((ip2int_1 << 8) | ip2int_2) << 8) | ip2int_3) << 8) | ip2int_4))"
}

int2ip() {
  int2ip_ui32="$1"; shift
  int2ip_ip=""
  [ -n "$int2ip_ui32" ] && [ "$int2ip_ui32" -ge 0 ] && [ "$int2ip_ui32" -le 4294967295 ] && for n in 1 2 3 4; do
    int2ip_ip="$((int2ip_ui32 & 0xff))${int2ip_ip:+.}$int2ip_ip"
    int2ip_ui32="$((int2ip_ui32 >> 8))"
  done
  printf "%s" "${int2ip_ip}"
}

network_v4() {
  network_v4_ia="$(echo "$1" | cut -d/ -f1)"
  network_v4_netmask="$(echo "$1" | cut -d/ -f2-)"
  if [ -n "$network_v4_netmask" ] && [ "$network_v4_netmask" -ge 0 ] && [ "$network_v4_netmask" -le 32 ]; then
    network_v4_addr="$(ip2int $network_v4_ia)"
    network_v4_mask="$((0xffffffff << (32 - network_v4_netmask)))"
    if [ "$network_v4_netmask" -eq 32 ]; then
      printf "%s" $(int2ip $((network_v4_addr & network_v4_mask)))
    else
      printf "%s/%s" "$(int2ip $((network_v4_addr & network_v4_mask)))" "$network_v4_netmask"
    fi
  fi
}

network_v6() {
  printf "%s" "$1"
}

normalize_ip() {
  # split by ":"
  normalize_ip_type="$( echo $1 | cut -s -d\: -f1)"
  normalize_ip_value="$( echo $1 | cut -s -d\: -f2-)"
    normalize_ip_IP=""
  if [ x"${normalize_ip_type}" = x"ip4" ] ; then
    # check if is a CIDR
    if expr "x${normalize_ip_value}" : "x.*/[0-9]*" > /dev/null; then
      normalize_ip_IP="$(network_v4 "${normalize_ip_value}")"
    else
      normalize_ip_IP="$(network_v4 "${normalize_ip_value}/32")"
    fi
  elif [ x"${normalize_ip_type}" = x"ip6" ]; then
    normalize_ip_IP="$(network_v6 "${normalize_ip_value}")"
  fi
  printf "%s" "$normalize_ip_IP"
}

# Create host query function
query_host() {
  "${spftoolspath}"/despf.sh "$1" | (grep -Ei ^ip || true ) >> "${tmp1}"
}

query_black_host() {
  "${spftoolspath}"/despf.sh "$1" | (grep -Ei ^ip || true ) >> "${blktmp1}"
}

# Create progress dots function
show_dots() {
  while ps "$1" >/dev/null ; do
  printf "."
  sleep 1
  done
  printf "\n"
}

# Fix mode
fix_invalid_ip() {
  fix_invalid_ip_iptype="$( echo "$1" | cut -d\: -f1 )"
  fix_invalid_ip_ip="$(normalize_ip "$1")"
  if [ -n "$fix_invalid_ip_ip" ]; then
    if [ x"$fix_invalid_ip_iptype" = x"ip4" ]; then
      printf "$(eval printf "%s" "\${${2}_line_v4}")" "$fix_invalid_ip_ip"
    elif [ x"$fix_invalid_ip_iptype" = x"ip6" ] ; then
      printf "$(eval printf "%s" "\${${2}_line_v6}")" "$fix_invalid_ip_ip"
    fi
  fi
}

# Remove mode
remove_invalid_ip() {
  remove_invalid_ip_iptype="$( echo "$1" | cut -d\: -f1 )"
  remove_invalid_ip_origip="$( echo "$1" | cut -d\: -f2- )"
  remove_invalid_ip_ip="$(normalize_ip "$1")"
  if [ x"$remove_invalid_ip_origip" = x"$remove_invalid_ip_ip" ]; then
    if [ x"$remove_invalid_ip_iptype" = x"ip4" ]; then
      printf "$(eval printf "%s" "\${${2}_line_v4}")" "$remove_invalid_ip_ip"
    elif [ x"$remove_invalid_ip_iptype" = x"ip6" ] ; then
      printf "$(eval printf "%s" "\${${2}_line_v6}")" "$remove_invalid_ip_ip"
    fi
  fi
}

# Keep mode
keep_invalid_ip() {
  keep_invalid_ip_iptype="$( echo "$1" | cut -d\: -f1 )"
  keep_invalid_ip_ip="$( echo "$1" | cut -d\: -f2- )"
  if [ -n "$keep_invalid_ip_ip" ]; then
    if [ x"$keep_invalid_ip_iptype" = x"ip4" ]; then
      printf "$(eval printf "%s" "\${${2}_line_v4}")" "$keep_invalid_ip_ip"
    elif [ x"$keep_invalid_ip_iptype" = x"ip6" ] ; then
      printf "$(eval printf "%s" "\${${2}_line_v6}")" "$keep_invalid_ip_ip"
    fi
  fi
}

# Let's DO this!

printf "\nRecursively querying SPF records of selected whitelist mailers...\n"

# Query selected mailers

printf "\nQuerying webmail hosts...\n"

for h in ${webmail_hosts}; do
  query_host "${h}"
done

printf "\nQuerying social network hosts...\n"

for h in ${social_hosts}; do
  query_host "${h}"
done

printf "\nQuerying ecommerce hosts...\n"

for h in ${commerce_hosts}; do
  query_host "${h}"
done

printf "\nQuerying bulk mail hosts...\n"

for h in ${bulk_hosts}; do
  query_host "${h}"
done

printf "\nQuerying miscellaneous hosts...\n"

for h in ${misc_hosts}; do
  query_host "${h}"
done

printf "\nQuerying custom hosts...\n"

for h in ${custom_hosts}; do
  query_host "${h}"
done

if [ x"$include_yahoo" = x"yes" ] ; then
  printf "\nIncluding scraped Yahoo! outbound hosts...\n"

  cat "${yahoo_static_hosts}" >> "${tmp1}"
fi

if [ x"$enable_blacklist" = x"yes" ] ; then
  printf "\nQuerying blacklist hosts...\n"

  for h in ${blacklist_hosts}; do
    query_black_host "${h}"
  done
fi

# If enabled, simplify (remove) any individual IPs already included in CIDR ranges (disabled by default)
if [ x"$simplify" = x"yes" ]; then
  printf "\nSimplifying whitelist IP addresses already included in CIDR ranges. These calculations\n"
  printf "can take a LONG time if you have many mailers selected. Please be patient..."

  cat "${tmp1}" | sort -u | "${spftoolspath}"/simplify.sh > "${tmp2}" &
  show_dots "$!"

  if [ x"$enable_blacklist" = x"yes" ] ; then
    printf "\nSimplifying blacklist IP addresses already included in CIDR ranges. These calculations\n"
      printf "can take a LONG time if you have many mailers selected. Please be patient..."
      cat "${blktmp1}" | sort -u | "${spftoolspath}"/simplify.sh > "${blktmp2}" &
      show_dots "$!"
  fi

  printf "\nIP address simplification complete.\n"
else
  cat "${tmp1}" > "${tmp2}"
  if [ x"$enable_blacklist" = x"yes" ] ; then
    cat "${blktmp1}" > "${blktmp2}"
  fi
fi

# Check for invalid IPv4 CIDRs, then format the whitelist

# If enabled, fix invalid CIDRs
if [ x"$invalid_ip4" = x"fix" ] ; then
  printf "\nFixing invalid whitelist IPv4 CIDRs..."
  cat "${tmp2}" | while read ip; do
    fix_invalid_ip "$ip" "permit"
  done >> "${tmp3}" &
  show_dots "$!"

  if [ x"$enable_blacklist" = x"yes" ] ; then
    printf "\nFixing invalid blacklist IPv4 CIDRs..."
    cat "${blktmp2}" | while read ip; do
      fix_invalid_ip "$ip" "reject"
    done >> "${blktmp3}" &
      show_dots "$!"
  fi

# If enabled, remove invalid CIDRs
elif [ x"$invalid_ip4" = x"remove" ] ; then
  printf "\nRemoving invalid IPv4 CIDRs from whitelist..."
  cat "${tmp2}" | while read ip; do
    remove_invalid_ip "$ip" "permit"
  done >> "${tmp3}" &
  show_dots "$!"

  if [ x"$enable_blacklist" = x"yes" ] ; then
    printf "\nRemoving invalid IPv4 CIDRs from blacklist..."
    cat "${blktmp2}" | while read ip; do
      remove_invalid_ip "$ip" "reject"
    done >> "${blktmp3}" &
    show_dots "$!"
  fi

# If enabled, keep invalid CIDRs
elif [ x"$invalid_ip4" = x"keep" ] ; then
  printf "\nKeeping invalid whitelist IPv4 CIDRs...\n"
  cat "${tmp2}" | while read ip; do
    keep_invalid_ip "$ip" "permit"
  done >> "${tmp3}" &
  show_dots "$!"

  if [ x"$enable_blacklist" = x"yes" ] ; then
    printf "\nKeeping invalid blacklist IPv4 CIDRs...\n"
    cat "${blktmp2}" | while read ip; do
      keep_invalid_ip "$ip" "reject"
    done >> "${blktmp3}" &
    show_dots "$!"
  fi
fi

# Sort, uniq, and count final rules
# Have to do sort and uniq separately, as 'sort -u -t. -k1,1n...' removes valid rules
printf "\nSorting whitelist rules...\n"
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n "${tmp3}" > "${tmp4}"
uniq "${tmp4}" >> "${tmp5}"
numrules="$(cat "${tmp5}" | wc -l)"

if [ x"$enable_blacklist" = x"yes" ] ; then
  printf "\nSorting blacklist rules...\n"
  sort -t. -k1,1n -k2,2n -k3,3n -k4,4n "${blktmp3}" > "${blktmp4}"
  uniq "${blktmp4}" >> "${blktmp5}"
  numblackrules="$(cat "${blktmp5}" | wc -l)"
fi

# Write whitelist and blacklist to Postfix directory
printf "\nWriting $numrules whitelist rules to ${postfixpath}/${whitelist}...\n"
printf "# Whitelist generated by Postwhite v$version on $(date)\n# https://github.com/stevejenkins/postwhite/\n# $numrules total rules\n" > "${postfixpath}"/"${whitelist}"
cat "${tmp5}" >> "${postfixpath}"/"${whitelist}"

if [ x"$enable_blacklist" = x"yes" ] ; then
  printf "\nWriting $numblackrules blacklist rules to ${postfixpath}/${blacklist}...\n"
  printf "# Blacklist generated by Postwhite v$version on $(date)\n# https://github.com/stevejenkins/postwhite/\n# $numblackrules total rules\n" > "${postfixpath}"/"${blacklist}"
  cat "${blktmp5}" >> "${postfixpath}"/"${blacklist}"
fi

# Remove temp files
cleanup() {
  test -e "${tmp1}" && rm "${tmp1}"
  test -e "${tmp2}" && rm "${tmp2}"
  test -e "${tmp3}" && rm "${tmp3}"
  test -e "${tmp4}" && rm "${tmp4}"
  test -e "${tmp5}" && rm "${tmp5}"
  if [ x"$enable_blacklist" = x"yes" ] ; then
    test -e "${blktmp1}" && rm "${blktmp1}"
    test -e "${blktmp2}" && rm "${blktmp2}"
    test -e "${blktmp3}" && rm "${blktmp3}"
    test -e "${blktmp4}" && rm "${blktmp4}"
    test -e "${blktmp5}" && rm "${blktmp5}"
  fi
}
cleanup

# Reload Postfix to pick up changes in whitelist
if [ x"$reload_postfix" = x"yes" ]; then
printf '\nReloading Postfix configuration to refresh rules...\n'
  ${postfixbinarypath}/postfix reload
fi

printf '\nDone!\n'

exit
