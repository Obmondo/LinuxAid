#! /bin/bash
# Time-stamp: <Sat 2019-02-02 00:38 svarrette>
################################################################################
# setup_slurm_accounting.sh - Utility script to create sample cluster, account
# and a set of users in the slurm accounting database

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SLURM_CLUSTERNAME=thor
SLURM_DEFAULTACCOUNT=ALLUSERS
SLURM_ALLOWED_QOS=ALL

print_error_and_exit(){ echo "***ERROR*** $*"; exit 1; }
usage() {
    cat<<EOF
$(basename $0) [-n] [--clustername NAME] [-a DEFAULTACCOUNT] [-l QOSLIST]

OPTIONS
  -n --dry-run
  -c --clustername NAME
     Define cluster name to set in the Slurm accounting
     Default: '${SLURM_CLUSTERNAME}'
  -a --account NAME
     Define the default account for the users. Default: '${SLURM_DEFAULTACCOUNT}'
  -l --qos-list QOS1[,QOS2...]
     Comma-separated list of allowed QOS for the default account ${SLURM_DEFAULTACCOUNT}.
     Default: '${SLURM_ALLOWED_QOS}'
EOF
}

###
# Setup sample Slurm accounting
##
vagrant_setup_slurm_accounting() {
    [ ! -d '/vagrant' ]        && return
    [ ! -x '/sbin/slurmctld' ] && return

    echo "=> Add cluster '${SLURM_CLUSTERNAME}' in accounting database"
    ${CMD_PREFIX} sacctmgr -i add cluster ${SLURM_CLUSTERNAME}

    qos_list="$(sacctmgr list qos -p --noheader | cut -d '|' -f 1 | paste -sd ',')"
    if  [[ "${qos_list}" == *normal* ]]; then
        echo "=> removing the default 'normal' QOS"
        ${CMD_PREFIX} sacctmgr -i delete qos normal
    fi
    # list QOS (except qos-admin)
    [ "${SLURM_ALLOWED_QOS}" == 'ALL' ] &&
        SLURM_ALLOWED_QOS="$(sacctmgr list qos -p --noheader | cut -d '|' -f 1 | grep -v 'admin' | paste -sd ',')"
    echo "=> add account ${SLURM_DEFAULTACCOUNT} (and associate users-* to it)"
    ${CMD_PREFIX} sacctmgr -i add account ${SLURM_DEFAULTACCOUNT} Cluster=${SLURM_CLUSTERNAME} QOS=${SLURM_ALLOWED_QOS}
    for u in $(getent passwd | grep '^user' | cut -d ':' -f 1); do
        ${CMD_PREFIX} sacctmgr -i add user ${u}   DefaultAccount=${SLURM_DEFAULTACCOUNT}
    done
    echo "=> restarting slurmctld service"
    ${CMD_PREFIX} systemctl restart slurmctld
}

######## Let's go #########
[ -z "$(which sacctmgr)" ] && print_error_and_exit "Unable to find 'sacctmgr' command"

# Check for options
while [ $# -ge 1 ]; do
    case $1 in
        -h | --help)    usage;        exit 0;;
        -n | --dry-run) CMD_PREFIX="echo";;
        -c | --cluster*) shift; SLURM_CLUSTERNAME=$1;;
        -a | --account | --defaultaccount) shift; SLURM_DEFAULTACCOUNT=$1;;
        -l | --qos*)     shift; SLURM_ALLOWED_QOS=$1;;
    esac
    shift
done

vagrant_setup_slurm_accounting

exit 0  # enforce successful completion
