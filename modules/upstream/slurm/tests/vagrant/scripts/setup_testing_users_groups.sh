#!/usr/bin/env bash
# Time-stamp: <Fri 2019-02-01 12:42 svarrette>
###############################################
# Utility script to create sample users

STARTDIR="$(pwd)"
SCRIPTFILENAME=$(basename $0)
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Shared directory hosting common files
VAGRANT_SHARED_DIR='/shared'

USERGROUP=clusterusers
GID=666
START_UID=5000
LOGIN_PREFIX=user-
HOME_BASEDIR=/shared/users

usage() {
    cat<<EOF
$(basename $0) [-n] [-g GROUP] [--gid GID] [--user-prefix PREFIX] [--start-uid N]
   Create sample group ${USERGROUP} (git ${GID}) and attached
   users '${LOGIN_PREFIX}[1-2]" for slurm accounting checks

OPTIONS
  -n --dry-run
  -g --group GROUP  Define group name. Default: '${USERGROUP}'
  --gid GID.        Default: ${GID}
  -p --prefix --user-prefix PREFIX
     Define prefix to use for the login/user created. Default: '${LOGIN_PREFIX}'
  --start-uid
     Starting UID of the created users.
     Default: '${START_UID}' i.e. the first user will have UID $(( START_UID+1 ))
EOF
}

###
# Add testing users and group
##
vagrant_setup_testing_users_groups() {
    [ ! -d '/vagrant' ]     && return
    local basedir="${HOME_BASEDIR}"
    # local ssh_id_rsa='id_rsa_testing'
    [ ! -d "${basedir}" ] && basedir='/home'

    echo "=> Add testing users and group"
    echo "   - setup group '${USERGROUP}'"
    ${CMD_PREFIX} groupadd -g ${GID} ${USERGROUP}
    ${CMD_PREFIX} usermod -G ${USERGROUP} vagrant

    # echo '   - prepare a shared testing ssh key'
    # install -o vagrant -g vagrant -m 600 ${VAGRANT_SHARED_DIR}/.ssh/${ssh_id_rsa} ~vagrant/.ssh/${ssh_id_rsa}
    # sudo -u vagrant cat ${VAGRANT_SHARED_DIR}/.ssh/${ssh_id_rsa}.pub >> ~vagrant/.ssh/authorized_keys

    # echo '   - feeding /etc/skel/.ssh'
    # mkdir -p /etc/skel/.ssh
    # install -o root -g root -m 600 ${VAGRANT_SHARED_DIR}/.ssh/${ssh_id_rsa} /etc/skel/.ssh/${ssh_id_rsa}
    # cat ${VAGRANT_SHARED_DIR}/.ssh/${ssh_id_rsa}.pub >> /etc/skel/.ssh/authorized_keys

    # create two sample users
    for i in $(seq 1 2); do
        u="${LOGIN_PREFIX}$i"
        n=$(expr $START_UID + $i)
        echo "=> adding testing user '$u' with uid $n"
        ${CMD_PREFIX} useradd -b ${basedir} -u ${n} -g ${USERGROUP} ${u} --create-home
    done
    # On slurm controller, they should be know but not allowed to connect
    if [ -x '/sbin/slurmctld' ]; then
        access_conf=/etc/security/access.conf
        if  grep --quiet "${USERGROUP}" ${access_conf}; then
            echo "=> group ${USERGROUP} already denied in ${access_conf}"
        else
            echo "=> denying access to group ${USERGROUP}"
            [ -z "${CMD_PREFIX}" ] && echo "-:${USERGROUP}:ALL" >> $access_conf
        fi
    fi
}


######## Let's go #########
# Check for options
while [ $# -ge 1 ]; do
    case $1 in
        -h | --help)  usage; exit 0;;
        -g | --group) shift; USERGROUP=$1;;
        -n | --dry-run) CMD_PREFIX="echo";;
        -p | --prefix | --user*) shift; LOGIN_PREFIX=$1;;
        --gid) shift; GID=$1;;
        --*uid) shift; START_UID=$1;;
    esac
    shift
done


vagrant_setup_testing_users_groups

exit 0 # enforce successful completion
