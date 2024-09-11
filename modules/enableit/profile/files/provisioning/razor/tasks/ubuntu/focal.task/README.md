# Task notes for Ubuntu 20.04 (Focal Fossa)

## Creating the repo
```sh
razor create-repo \
      --name=ubuntu-20.04 \
      --url https://mirrors.dotsrc.org/ubuntu-cd/focal/ubuntu-20.04-live-server-amd64.iso \
      --task ubuntu/focal

cd /opt/puppetlabs/server/data/razor-server/repo/ubuntu-20.04/
wget https://mirrors.dotsrc.org/ubuntu-cd/focal/ubuntu-20.04-live-server-amd64.iso
mkdir -p /mnt/loop0
mount -o loop ubuntu-20.04-live-server-amd64.iso /mnt/loop0
cp /mnt/loop0/casper/{vmlinuz,initrd}
/opt/puppetlabs/server/data/razor-server/repo/ubuntu-20.04/
umount /mnt/loop0
```
