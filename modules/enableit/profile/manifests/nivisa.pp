# NI-VISA Profile
class profile::nivisa (
  Boolean $enable = $common::extras::computing::nivisa::enable,
) {

  eit_repos::yum::ni_visa.include

  package::install([
    'dkms',
    'elfutils-libelf-devel',
    'labview-rte.x86_64',
    'libniqpxi1',
    'libvisa',
    'libvisa-data',
    'libnidimu1',
    'libnipxirm1',
    'ni-apal-errors.noarch',
    'ni-avahi-client.x86_64',
    'ni-dim-dkms.x86_64',
    'ni-euladepot.noarch',
    'ni-kal.noarch',
    'ni-mdbg.x86_64',
    'ni-mdbg-dkms.x86_64',
    'ni-mdbg-errors.noarch',
    'ni-mxdf.x86_64',
    'ni-mxdf-dkms.x86_64',
    'ni-mxdf-errors.noarch',
    'ni-networkdiscoverysvc.x86_64',
    'ni-orb.x86_64',
    'ni-orb-dkms.x86_64',
    'ni-orb-errors.noarch',
    'ni-orb-tools.x86_64',
    'ni-pal.x86_64',
    'ni-pal-dkms.x86_64',
    'ni-pal-errors.noarch',
    'ni-pal-support.noarch',
    'ni-pxipf-errors.noarch',
    'ni-pxipf-nipxirm-bin.x86_64',
    'ni-pxipf-nipxirm-dkms.x86_64',
    'ni-pxisa-compliance.noarch',
    'ni-routing-errors.noarch',
    'ni-service-locator.x86_64',
    'ni-software.noarch',
    'ni-sysapi.x86_64',
    'ni-syscfg-runtime.x86_64',
    'ni-visa.noarch',
    'ni-visa-config.x86_64',
    'ni-visa-ddw.x86_64',
    'ni-visa-devel.noarch',
    'ni-visa-doc.noarch',
    'ni-visa-errors.noarch',
    'ni-visa-headers.noarch',
    'ni-visa-interactive-control.x86_64',
    'ni-visa-labview-io-control.x86_64',
    'ni-visa-labview-rc.noarch',
    'ni-visa-lxi-discovery.x86_64',
    'ni-visa-passport-enet.x86_64',
    'ni-visa-passport-enet-serial.x86_64',
    'ni-visa-passport-gpib.x86_64',
    'ni-visa-passport-pxi.x86_64',
    'ni-visa-passport-pxi-dkms.x86_64',
    'ni-visa-passport-remote.x86_64',
    'ni-visa-passport-serial.x86_64',
    'ni-visa-passport-usb.x86_64',
    'ni-visa-runtime.noarch',
    'ni-visa-server.x86_64',
    'ni-visa-sysapi.x86_64',
    'ni-wsrepl.x86_64',
    'nicurli.x86_64',
    'nisslcerts.noarch',
    'nissli.x86_64',
    'niswactions.x86_64',
    'nitargetcfgi.x86_64',
  ], {
    require => Yumrepo['ni-software'],
    notify  => Exec['DKMS autoinstall for NI-VISA kernel modules'],
  })

  exec { 'DKMS autoinstall for NI-VISA kernel modules':
    command     => '/sbin/dkms autoinstall',
    refreshonly => true,
  }

  [
    'nipxirmk',
    'nimxdfk',
    'nimdbgk',
    'nidimk',
    'niorbk',
    'NiViPciK',
    'nipalk',
    'nikal'
  ].each |$mod| {
    kmod::load { $mod: }
  }

  # It seems like there is a possible bug in the installer for NI VISA/init
  # scripts, which causes these services to not be started at boot when running
  # on a systemd system. See e.g.
  # https://forums.ni.com/t5/Instrument-Control-GPIB-Serial/libnipalu-so-failed-to-initialize/td-p/3316549
  # for an example of the same issue.
  if $facts['init_system'] == 'systemd' {
    service { [
      'nisvcloc',
      'nipal',
      'nilxid',
      'ni-pxipf-nipxirm-bind',
    ]:
      ensure => 'running',
      enable => true,
    }
  }

}
