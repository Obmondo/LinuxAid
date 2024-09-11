# == Type: vagrant::package
#
# === Copyright
#
# Copyright 2015 North Development AB
#

define vagrant::package (
  $ensure               = latest,
  $version              = undef,
  $source               = undef,
  $provider             = undef,
  $path                 = $::path
) {

  # The $old_versions hash stores git tag references
  # for versions >= 1.0 and < 1.4
  $old_versions = {
    '1.1.0' => '194948999371e9aee391d13845a0bdeb27e51ac0',
    '1.1.1' => 'f743fed3cc0466839a97d4724ec0995139f87806',
    '1.1.2' => '67bd4d30f7dbefa7c0abc643599f0244986c38c8',
    '1.1.3' => '0903e62add3d6c44ce6ad31ce230f3092be445eb',
    '1.1.4' => '87613ec9392d4660ffcb1d5755307136c06af08c',
    '1.1.5' => '64e360814c3ad960d810456add977fd4c7d47ce6',
    '1.2.0' => 'f5ece47c510e5a632adb69701b78cb6dcbe03713',
    '1.2.1' => 'a7853fe7b7f08dbedbc934eb9230d33be6bf746f',
    '1.2.2' => '7e400d00a3c5a0fdf2809c8b5001a035415a607b',
    '1.2.3' => '95d308caaecd139b8f62e41e7add0ec3f8ae3bd1',
    '1.2.4' => '0219bb87725aac28a97c0e924c310cc97831fd9d',
    '1.2.5' => 'ec2305a9a636ba8001902cecb835a00e71a83e45',
    '1.2.6' => '22b76517d6ccd4ef232a4b4ecbaa276aff8037b8',
    '1.2.7' => '7ec0ee1d00a916f80b109a298bab08e391945243',
    '1.3.0' => '0224c6232394680971a69d94dd55a7436888c4cb',
    '1.3.1' => 'b12c7e8814171c1295ef82416ffe51e8a168a244',
    '1.3.2' => '9a394588a6dcf97e8f916da9564088fcf242c4b3',
    '1.3.3' => 'db8e7a9c79b23264da129f55cf8569167fc22415',
    '1.3.4' => '0ac2a87388419b989c3c0d0318cc97df3b0ed27d',
    '1.3.5' => 'a40522f5fabccb9ddabad03d836e120ff5d14093'
  }

  # avoid hitting www.vagrantup.com unless we want to know the version
  $version_real = $version ? {
    undef   => get_latest_vagrant_version(),
    default => $version
  }

  # Determine the base url (it depends on the version)
  if versioncmp($version_real, '1.4.0') >= 0 {
    $base_url = "https://releases.hashicorp.com/vagrant/${version_real}"
    $darwin_prefix = 'vagrant_'
    $windows_prefix = 'vagrant_'
  } else {
    $base_url = "http://files.vagrantup.com/packages/${old_versions[$version_real]}"
    $darwin_prefix = 'Vagrant-'
    $windows_prefix = 'Vagrant_'
  }

  # Set file suffix according to the architecture
  case $::architecture {
    'x86_64', 'amd64': {
      $arch_suffix = 'x86_64'
    }
    'i386': {
      $arch_suffix = 'i686'
    }
    default: {
      fail("Unsupported architecture: ${::architecture}")
    }
  }

  # Finally determine download url
  case $::osfamily {
    'redhat': {
      $vagrant_source = $source ? {
        undef   => "${base_url}/vagrant_${version_real}_${arch_suffix}.rpm",
        default => $source
      }
    }
    'darwin': {
      $vagrant_source = $source ? {
        undef   => "${base_url}/${darwin_prefix}${version_real}.dmg",
        default => $source
      }
    }
    'debian': {
      $download_source = $source ? {
        undef   => "${base_url}/vagrant_${version_real}_${arch_suffix}.deb",
        default => $source
      }
      $vagrant_source = "${::ostempdir}/vagrant_${version_real}_${arch_suffix}.deb"

      exec { 'vagrant-download':
        command => "wget -O ${vagrant_source} ${download_source}",
        creates => $vagrant_source,
        timeout => 0,
        path    => $path,
        before  => Package['vagrant']
      }
    }
    'windows': {
      $download_source = $source ? {
        undef   => "${base_url}/${windows_prefix}${version_real}.msi",
        default => $source
      }
      $vagrant_source = "${::ostempdir}\\${windows_prefix}${version_real}.msi"

      exec { 'vagrant-download':
        command => "powershell.exe -ExecutionPolicy Unrestricted -Command \"(New-Object Net.WebClient).DownloadFile('${download_source}', '${vagrant_source}')\"",
        creates => $vagrant_source,
        timeout => 0,
        path    => $path,
        before  => Package['vagrant'],
      }
    }
    default: {
      fail("Unsupported OS family: ${::osfamily}")
    }
  }

  package { 'vagrant':
    ensure => $ensure,
    source => $vagrant_source
  }

  if $provider != undef {
    Package['vagrant'] { provider => $provider }
  }
}
