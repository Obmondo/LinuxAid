# Nvidia Driver
class profile::software::nvidia_driver (
  Boolean               $enable     = $common::software::nvidia_driver::enable,
  Eit_types::Noop_Value $noop_value = $common::software::nvidia_driver::noop_value,
) {

  confine(
    $facts['os']['name'] == 'Debian' and versioncmp(facts['os']['release']['major'], '10') <= 0,
    'Only Debian 10 and newer release are supported',
  )

  case $facts['os']['family'] {
    'Debian': {
      $distro = regsubst(downcase("${facts['os']['name']}${facts['os']['release']['full']}"), '\.', '', 'G')

      apt::source { 'Nvidia-Driver':
        ensure       => ensure_present($enable),
        location     => "https://developer.download.nvidia.com/compute/cuda/repos/${distro}/x86_64/",
        noop         => $noop_value,
        architecture => 'amd64',
        release      => '/',
        key          => {
          'id'     => 'EB693B3035CD5710E231E123A4B469963BF863CC',
          'source' => "https://developer.download.nvidia.com/compute/cuda/repos/${distro}/x86_64/3bf863cc.pub",
        },
      }
    }
    'RedHat': {
      $distro = $facts['os']['release']['major']

      yumrepo { 'Nvidia-Driver':
        ensure   => ensure_present($enable),
        baseurl  => "https://developer.download.nvidia.com/compute/cuda/repos/rhel${distro}/x86_64",
        enabled  => 1,
        noop     => $noop_value,
        gpgcheck => 1,
        gpgkey   => "https://developer.download.nvidia.com/compute/cuda/repos/rhel${distro}/x86_64/D42D0685.pub",
        descr    => "Nvidia-cuda repository for Rhel-${distro}",
      }
    }
    default: {
      fail('Not Supported')
    }
  }

  package { lookup('profile::software::nvidia_driver::packages'):
    ensure => ensure_present($enable),
    noop   => $noop_value,
  }
}
