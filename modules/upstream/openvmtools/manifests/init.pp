# @summary Install the Open Virtual Machine Tools.
#
# @param ensure
#   Ensure if present or absent.
#
# @param autoupgrade
#   Upgrade package automatically, if there is a newer version.
#
# @param desktop_package_conflicts
#   Boolean that determines whether the desktop conflicts includes and
#   conflicts with the base package. Only set this if your platform is not
#   supported or you know what you are doing.
#
# @param desktop_package_name
#   Name of the desktop package.
#   Only set this if your platform is not supported or you know what you are
#   doing.
#
# @param manage_epel
#   Boolean that determines if puppet-epel is required for packages.
#   This should only needed for RedHat (EL) 6.
#
# @param package_name
#   Name of the package.
#   Only set this if your platform is not supported or you know what you are
#   doing.
#
# @param service_enable
#   Start service at boot.
#
# @param service_ensure
#   Ensure if service is running or stopped.
#
# @param service_hasstatus
#   Service has status command.
#   Only set this if your platform is not supported or you know what you are
#   doing.
#
# @param service_name
#   Name of openvmtools service(s).
#   Only set this if your platform is not supported or you know what you are
#   doing.
#
# @param service_pattern
#   Pattern to look for in the process table to determine if the daemon is
#   running.
#   Only set this if your platform is not supported or you know what you are
#   doing.
#
# @param uninstall_vmware_tools
#   Boolean that determines whether the conflicting VMWare Tools package should
#   be uninstalled, if present.
#
# @param with_desktop
#   Whether or not to install the desktop/GUI support.
#
# @example Default usage
#   include openvmtools
#
# @author Mike Arnold <mike@razorsedge.org>
# @author Vox Pupuli <voxpupuli@groups.io>
#
class openvmtools (
  Enum['absent','present']            $ensure                    = 'present',
  Boolean                             $autoupgrade               = false,
  Boolean                             $desktop_package_conflicts = false,
  String[1]                           $desktop_package_name      = 'open-vm-tools-desktop',
  Boolean                             $manage_epel               = false,
  String[1]                           $package_name              = 'open-vm-tools',
  Boolean                             $service_enable            = true,
  Stdlib::Ensure::Service             $service_ensure            = 'running',
  Boolean                             $service_hasstatus         = true,
  Variant[String[1],Array[String[1]]] $service_name              = ['vgauthd', 'vmtoolsd'],
  Optional[String[1]]                 $service_pattern           = undef,
  Optional[Boolean]                   $supported                 = undef,
  Boolean                             $uninstall_vmware_tools    = false,
  Boolean                             $with_desktop              = false,
) {
  if $facts['virtual'] == 'vmware' {
    if pick($supported, openvmtools::supported($module_name)) {
      if $ensure == 'present' {
        $package_ensure = $autoupgrade ? {
          true    => 'latest',
          default => 'present',
        }
        $service_ensure_real = $service_ensure
      } else { # ensure == 'absent'
        $package_ensure = 'absent'
        $service_ensure_real = 'stopped'
      }

      $packages = $with_desktop ? {
        true    => $desktop_package_conflicts ? {
          true    => [$desktop_package_name],
          default => [$package_name, $desktop_package_name],
        },
        default => [$package_name],
      }

      if $manage_epel {
        include epel
        Yumrepo['epel'] -> Package[$packages]
      }

      if $uninstall_vmware_tools {
        if $facts['vmware_uninstaller'] =~ Stdlib::Unixpath {
          $vmware_lib = regsubst( $facts['vmware_uninstaller'],
            'bin/vmware-uninstall-tools.pl',
            'lib/vmware-tools'
          )
          exec { 'vmware-uninstall-tools':
            command => "${facts['vmware_uninstaller']} && rm -rf ${vmware_lib} ${facts['vmware_uninstaller']}",
            before  => Package['VMwareTools'],
          }
        }
        package { 'VMwareTools':
          ensure => 'absent',
          before => Package[$packages],
        }
      }

      package { $packages:
        ensure => $package_ensure,
      }

      file { '/var/run/vmware':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }
      -> service { $service_name:
        ensure    => $service_ensure_real,
        enable    => $service_enable,
        hasstatus => $service_hasstatus,
        pattern   => $service_pattern,
        require   => Package[$packages],
      }
    } else { # ! $supported
      notice("Your operating system ${facts['os']['name']} is unsupported and will not have the Open Virtual Machine Tools installed.")
    }
  } else {
    # If we are not on VMware, do not do anything.
  }
}
