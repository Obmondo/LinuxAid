# Nvidia Driver
class profile::software::nvidia_driver (
  Boolean           $enable     = $common::software::nvidia_driver::enable,
  Optional[Boolean] $noop_value = $common::software::nvidia_driver::noop_value,
){

  case $facts['os']['family'] {
    'Debian':{
      $distro = regsubst(downcase("${facts['os']['name']}${facts['os']['release']['full']}"), '\.', '', 'G')

      apt::source { 'Nvidia-Driver':
        ensure       => ensure_present($enable),
        location     => "https://developer.download.nvidia.com/compute/cuda/repos/${distro}/x86_64/ /",
        noop         => $noop_value,
        architecture => 'amd64',
        release      => '',
        repos        => '',
        key          => {
          'id'     => 'EB693B3035CD5710E231E123A4B469963BF863CC',
          'source' => 'https://developer.download.nvidia.com/compute/cuda/repos/GPGKEY',
        },
      }

      package { 'cuda-drivers':
        ensure => ensure_present($enable),
        noop   => $noop_value,
      }
    }

    'RedHat':{
      $distro = $facts['os']['release']['major']

      yumrepo { 'Nvidia-Driver' :
        ensure   => ensure_present($enable),
        baseurl  => "https://developer.download.nvidia.com/compute/cuda/repos/rhel${distro}/x86_64",
        enabled  => 1,
        noop     => $noop_value,
        gpgcheck => 1,
        gpgkey   => "https://developer.download.nvidia.com/compute/cuda/repos/rhel${distro}/x86_64/D42D0685.pub",
        descr    => "Nvidia-cuda repository for Rhel-${distro}",
      }

      package { ['kernel-devel', 'kernel-headers']:
        ensure => ensure_present($enable),
        noop   => $noop_value,
      }

      package { ['nvidia-driver-latest-dkms', 'cuda']:
        ensure  => ensure_present($enable),
        noop    => $noop_value,
        require => Package['kernel-devel', 'kernel-headers'],
      }
    }
    default : { fail('Not Supported') }
  }
}
