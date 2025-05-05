# VirtualBox Profile
class profile::virtualization::virtualbox{
  stdlib::ensure_packages(['dpkg-dev', 'virtualbox', 'linux-headers-generic', 'linux-image-generic', 'linux-generic'])
}
