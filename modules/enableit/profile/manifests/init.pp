####################################################
# Loaded by ALL customers                          #
####################################################
class profile (
) {

  Package { allow_virtual => false, }

  if $facts[os][family] == 'RedHat' {
    # NOTE: The below line means we don't want the razor postinstall script to be
    # run at boot time. Its a leftover after Razor completed the installation of
    # the node. #3304
    file_line { 'razor_postinstall':
      ensure => absent,
      path   => '/etc/rc.local',
      line   => 'bash /root/razor_postinstall.sh',
    }

    file_line { 'rc.d-razor_postinstall':
      ensure => absent,
      path   => '/etc/rc.d/rc.local',
      line   => 'bash /root/razor_postinstall.sh',
    }
  }

  # Contain Class
  contain ::common
  contain ::profile::system
}
