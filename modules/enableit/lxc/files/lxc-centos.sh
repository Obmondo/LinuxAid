#!/bin/bash

#
# template script for generating CentOS container for LXC
#

#
# lxc: linux Container library

# Authors:
# Daniel Lezcano <daniel.lezcano@free.fr>
# Ramez Hanna <rhanna@informatiq.org>

# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.

# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.

# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

#Configurations
arch=$(arch)
release=6
cache_base=/var/cache/lxc/centos/$arch
default_path=/var/lib/lxc
root_password=password

# is this centos?
[ -f /etc/redhat-release ] && is_centos=true

if [ "$arch" = "i686" ]; then
    arch=i386
fi

configure_centos()
{

    # disable selinux in centos
    mkdir -p $rootfs_path/selinux
    echo 0 > $rootfs_path/selinux/enforce

   # configure the network using the dhcp
    cat <<EOF > ${rootfs_path}/etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=dhcp
ONBOOT=yes
TYPE=Ethernet
USERCTL=yes
PEERDNS=yes
IPV6INIT=no
DHCP_HOSTNAME="$(if [ -x /etc/hostname ] && [ ! -z `cat /etc/hostname` ] ; then cat /etc/hostname ; else hostname ; fi )"
EOF

    # set the dns
    cat > ${rootfs_path}/etc/resolv.conf << END
# Google public DNS
nameserver 8.8.8.8
nameserver 8.8.4.4
END


    # set the hostname
    cat <<EOF > ${rootfs_path}/etc/sysconfig/network
NETWORKING=yes
HOSTNAME=${name}
EOF

    # set minimal hosts
    cat <<EOF > $rootfs_path/etc/hosts
127.0.0.1 localhost $name
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
EOF

    sed -i 's|.sbin.start_udev||' ${rootfs_path}/etc/rc.sysinit
    sed -i 's|.sbin.start_udev||' ${rootfs_path}/etc/rc.d/rc.sysinit
    # don't mount devpts, for pete's sake
    sed -i 's/^.*dev.pts.*$/#\0/' ${rootfs_path}/etc/rc.sysinit
    sed -i 's/^.*dev.pts.*$/#\0/' ${rootfs_path}/etc/rc.d/rc.sysinit

    sed -i 's/^.*dev.pts.*$/#\0/' ${rootfs_path}/etc/rc.d/rc.sysinit
    sed -i 's/^.*dev.pts.*$/#\0/' ${rootfs_path}/etc/rc.d/rc.sysinit
    sed -i 's/^.*dev.pts.*$/#\0/' ${rootfs_path}/etc/rc.d/rc.sysinit

    sed -i 's/^#baseurl/baseurl/g' ${rootfs_path}/etc/yum.repos.d/CentOS-Base.repo
    sed -i "s/\$releasever/$release.$releaseminor/g" ${rootfs_path}/etc/yum.repos.d/CentOS-Base.repo
    sed -i '115,126s/^/#/' ${rootfs_path}/etc/rc.d/init.d/halt

    chroot ${rootfs_path} chkconfig udev-post off
    chroot ${rootfs_path} chkconfig network on

    dev_path="${rootfs_path}/dev"
    rm -rf $dev_path
    mkdir -p $dev_path
    mknod -m 666 ${dev_path}/null c 1 3
    mknod -m 666 ${dev_path}/zero c 1 5
    mknod -m 666 ${dev_path}/random c 1 8
    mknod -m 666 ${dev_path}/urandom c 1 9
    mkdir -m 755 ${dev_path}/pts
    mkdir -m 1777 ${dev_path}/shm
    mknod -m 666 ${dev_path}/tty c 5 0
    mknod -m 666 ${dev_path}/tty0 c 4 0
    mknod -m 666 ${dev_path}/tty1 c 4 1
    mknod -m 666 ${dev_path}/tty2 c 4 2
    mknod -m 666 ${dev_path}/tty3 c 4 3
    mknod -m 666 ${dev_path}/tty4 c 4 4
    mknod -m 600 ${dev_path}/console c 5 1
    mknod -m 666 ${dev_path}/full c 1 7
    mknod -m 600 ${dev_path}/initctl p
    mknod -m 666 ${dev_path}/ptmx c 5 2

    echo "setting root passwd to $root_password"
    echo "root:$root_password" | chroot $rootfs_path chpasswd

    # specifying this in the initial packages doesn't always work.
#    echo "installing centos-release package"
#    if [ ! -f ${rootfs_path}/etc/resolv.conf ]; then
#      cp /etc/resolv.conf ${rootfs_path}/etc/resolv.conf
#      remove_resolv=1
#    fi
#    chroot ${rootfs_path} rpm --rebuilddb
#    chroot ${rootfs_path} yum --releasever=${release} -y install centos-release
#    if [ ! -z $remove_resolv ]; then
#      rm ${rootfs_path}/etc/resolv.conf
#    fi

    # silence some needless startup errors
    touch ${rootfs_path}/etc/fstab

    # give us a console on /dev/console
    sed -i 's/ACTIVE_CONSOLES=.*$/ACTIVE_CONSOLES="\/dev\/console \/dev\/tty[1-4]"/' \
        ${rootfs_path}/etc/sysconfig/init

    return 0
}

download_centos()
{

    # check the mini centos was not already downloaded
    INSTALL_ROOT=$cache/partial
    mkdir -p $INSTALL_ROOT
    if [ $? -ne 0 ]; then
  echo "Failed to create '$INSTALL_ROOT' directory"
  return 1
    fi

    # download a mini centos into a cache
    echo "Downloading centos minimal ..."
    YUM="yum --installroot $INSTALL_ROOT -y --nogpgcheck"
    PKG_LIST="yum initscripts passwd rsyslog vim-minimal dhclient chkconfig"
    PKG_LIST="$PKG_LIST rootfiles policycoreutils centos-release openssh-server avahi"
    PKG_LIST="$PKG_LIST openssh-clients sudo plymouth"
    MIRRORLIST_URL="http://mirrorlist.centos.org/?release=$release&arch=$arch&repo=os"

    DOWNLOAD_OK=no
    for trynumber in 1 2 3; do
        [ $trynumber != 1 ] && echo "Trying again..."
        MIRROR_URL=$(curl -s -S -f "$MIRRORLIST_URL" | head -n2 | tail -n1)
        if [ $? -ne 0 ] || [ -z "$MIRROR_URL" ]; then
            echo "Failed to get a mirror"
            continue
        fi
        RELEASE_URL="$MIRROR_URL/Packages/centos-release-$release-$releaseminor.el6.centos.11.1.$arch.rpm"
        echo "Fetching from $RELEASE_URL"
        curl -f "$RELEASE_URL" > $INSTALL_ROOT/centos-release-$release-$releaseminor.centos.$arch.rpm
        if [ $? -ne 0 ]; then
            echo "Failed to download centos release rpm"
            continue
        fi
        DOWNLOAD_OK=yes
        break
    done
    if [ $DOWNLOAD_OK != yes ]; then
        echo "Aborting"
        return 1
    fi

    mkdir -p $INSTALL_ROOT/var/lib/rpm
    rpm --root $INSTALL_ROOT  --initdb
    rpm --root $INSTALL_ROOT -ivh $INSTALL_ROOT/centos-release-$release-$releaseminor.centos.$arch.rpm
    $YUM install $PKG_LIST
    chroot $INSTALL_ROOT rm -f /var/lib/rpm/__*
    chroot $INSTALL_ROOT rpm --rebuilddb

    if [ $? -ne 0 ]; then
  echo "Failed to download the rootfs, aborting."
  return 1
    fi

    mv "$INSTALL_ROOT" "$cache/rootfs"
    echo "Download complete."

    return 0
}

copy_centos()
{

    # make a local copy of the minicentos
    echo -n "Copying rootfs to $rootfs_path ..."
    #cp -a $cache/rootfs-$arch $rootfs_path || return 1
    # i prefer rsync (no reason really)
    mkdir -p $rootfs_path
    rsync -a $cache/rootfs/ $rootfs_path/
    return 0
}

update_centos()
{
#    chroot $cache/rootfs yum -y update
  echo "Updates disabled"
}

install_centos()
{
    mkdir -p /var/lock/subsys/
    (
  flock -x 200
  if [ $? -ne 0 ]; then
      echo "Cache repository is busy."
      return 1
  fi

  echo "Checking cache download in $cache/rootfs ... "
  if [ ! -e "$cache/rootfs" ]; then
      download_centos
      if [ $? -ne 0 ]; then
    echo "Failed to download 'centos base'"
    return 1
      fi
        else
      echo "Cache found. Updating..."
            update_centos
      if [ $? -ne 0 ]; then
    echo "Failed to update 'centos base', continuing with last known good cache"
            else
                echo "Update finished"
      fi
  fi

  echo "Copy $cache/rootfs to $rootfs_path ... "
  copy_centos
  if [ $? -ne 0 ]; then
      echo "Failed to copy rootfs"
      return 1
  fi

  return 0

  ) 200>/var/lock/subsys/lxc

    return $?
}

copy_configuration()
{

    mkdir -p $config_path
    cat <<EOF >> $config_path/config
lxc.utsname = $name
lxc.tty = 4
lxc.pts = 1024
lxc.rootfs = $rootfs_path
lxc.mount  = $config_path/fstab

# uncomment the next line to run the container unconfined:
#lxc.aa_profile = unconfined

#cgroups
lxc.cgroup.devices.deny = a
# /dev/null and zero
lxc.cgroup.devices.allow = c 1:3 rwm
lxc.cgroup.devices.allow = c 1:5 rwm
# consoles
lxc.cgroup.devices.allow = c 5:1 rwm
lxc.cgroup.devices.allow = c 5:0 rwm
lxc.cgroup.devices.allow = c 4:0 rwm
lxc.cgroup.devices.allow = c 4:1 rwm
# /dev/{,u}random
lxc.cgroup.devices.allow = c 1:9 rwm
lxc.cgroup.devices.allow = c 1:8 rwm
lxc.cgroup.devices.allow = c 136:* rwm
lxc.cgroup.devices.allow = c 5:2 rwm
# rtc
lxc.cgroup.devices.allow = c 254:0 rwm
EOF

    cat <<EOF > $config_path/fstab
proc            proc         proc    nodev,noexec,nosuid 0 0
sysfs           sys          sysfs defaults  0 0
EOF
    if [ $? -ne 0 ]; then
  echo "Failed to add configuration"
  return 1
    fi

    return 0
}

clean()
{

    if [ ! -e $cache ]; then
  exit 0
    fi

    # lock, so we won't purge while someone is creating a repository
    (
  flock -x 200
  if [ $? != 0 ]; then
      echo "Cache repository is busy."
      exit 1
  fi

  echo -n "Purging the download cache for Centos-$release-$releaseminor..."
  rm --preserve-root --one-file-system -rf $cache && echo "Done." || exit 1
  exit 0

    ) 200>/var/lock/subsys/lxc
}

usage()
{
    cat <<EOF
usage:
    $1 -n|--name=<container_name>
        [-p|--path=<path>] [-c|--clean] [-R|--release=<Centos_release>] [-A|--arch=<arch of the container>]
        [-h|--help]
Mandatory args:
  -n,--name         container name, used to as an identifier for that container from now on
Optional args:
  -p,--path         path to where the container rootfs will be created, defaults to /var/lib/lxc. The container config will go under /var/lib/lxc in that case
  -c,--clean        clean the cache
  -R,--release      Centos release for the new container. if the host is Fedora, then it will defaultto the host's release.
  -m,--release-minor Minor release number for the new containar
  -A,--arch         NOT USED YET. Define what arch the container will be [i686,x86_64]
  -h,--help         print this help
EOF
    return 0
}

options=$(getopt -o hp:n:cR:m: -l help,path:,name:,clean,release:,releaseminor: -- "$@")
if [ $? -ne 0 ]; then
    usage $(basename $0)
    exit 1
fi
eval set -- "$options"

while true
do
    case "$1" in
  -h|--help)      usage $0 && exit 0;;
  -p|--path)      path=$2; shift 2;;
  -n|--name)      name=$2; shift 2;;
  -c|--clean)     clean=$2; shift 2;;
  -R|--release)   release=$2; shift 2;;
  -m|--releaseminor) releaseminor=$2; shift 2;;
  --)             shift 1; break ;;
        *)              break ;;
    esac
done

if [ ! -z "$clean" -a -z "$path" ]; then
    clean || exit 1
    exit 0
fi

needed_pkgs=""
type yum >/dev/null 2>&1
if [ $? -ne 0 ]; then
    needed_pkgs="yum $needed_pkgs"
fi

type curl >/dev/null 2>&1
if [ $? -ne 0 ]; then
    needed_pkgs="curl $needed_pkgs"
fi

if [ -n "$needed_pkgs" ]; then
    echo "Missing commands: $needed_pkgs"
    echo "Please install these using \"sudo apt-get install $needed_pkgs\""
    exit 1
fi

if [ -z "$path" ]; then
    path=$default_path
fi

if [ -z "$release" ]; then
    if [ "$is_centos" ]; then
        release=$(cat /etc/centos-release |awk '/^Fedora/ {print $3}')
    else
        echo "This is not a centos host and release missing, defaulting to 6.5. use -R|--release to specify release"
        release=6
    fi
fi

if [ -z "$releaseminor" ]; then
  releaseminor=5
fi

if [ "$(id -u)" != "0" ]; then
    echo "This script should be run as 'root'"
    exit 1
fi


rootfs_path=$path/rootfs
config_path=$default_path/$name
cache=$cache_base/$release

revert()
{
    echo "Interrupted, so cleaning up"
    lxc-destroy -n $name
    # maybe was interrupted before copy config
    rm -rf $path/$name
    rm -rf $default_path/$name
    echo "exiting..."
    exit 1
}

trap revert SIGHUP SIGINT SIGTERM

copy_configuration
if [ $? -ne 0 ]; then
    echo "failed write configuration file"
    exit 1
fi

install_centos
if [ $? -ne 0 ]; then
    echo "failed to install centos"
    exit 1
fi

configure_centos
if [ $? -ne 0 ]; then
    echo "failed to configure centos for a container"
    exit 1
fi


if [ ! -z $clean ]; then
    clean || exit 1
    exit 0
fi
echo "container rootfs and config created"
