# cat /opt/obmondo/razor/tasks/ubuntu/jammy.task/README.md
# Task notes for Ubuntu 22.04 (jammy jellyfish)

## Creating the repo
```sh
razor create-repo \
      --name=ubuntu-22.04 \
      --url https://mirrors.dotsrc.org/ubuntu-cd/jammy/ubuntu-22.04.1-live-server-amd64.iso \
      --task ubuntu/jammy

cd /opt/puppetlabs/server/data/razor-server/repo/ubuntu-22.04/
wget https://mirrors.dotsrc.org/ubuntu-cd/jammy/ubuntu-22.04.1-live-server-amd64.iso
mkdir -p /mnt/loop0
mount -o loop ubuntu-22.04.1-live-server-amd64.iso /mnt/loop0
cp /mnt/loop0/casper/{vmlinuz,initrd}
/opt/puppetlabs/server/data/razor-server/repo/ubuntu-22.04/
umount /mnt/loop0
```
