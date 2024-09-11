# VirtualBox Profile
class profile::virtualization::virtualbox{
  ensure_packages(['dpkg-dev', 'virtualbox', 'linux-headers-generic', 'linux-image-generic', 'linux-generic'])
}
