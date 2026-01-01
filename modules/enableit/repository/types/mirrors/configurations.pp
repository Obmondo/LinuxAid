type Repository::Mirrors::Configurations = Hash[
  Enum[
    'ubuntu',
    'ubuntu_arm64',
    'zabbix',
    'zabbix_non-supported',
    'epel',
    'docker',
    'microsoft',
    'jenkins',
    'openvox',
  ], Struct[{
    yum => Optional[Struct[{
      enable => Boolean,
      all    => Optional[Repository::Mirrors::Yum_Settings],
      el7    => Optional[Repository::Mirrors::Yum_Settings],
      el8    => Optional[Repository::Mirrors::Yum_Settings],
      el9    => Optional[Repository::Mirrors::Yum_Settings],
      sles12 => Optional[Repository::Mirrors::Yum_Settings],
      sles15 => Optional[Repository::Mirrors::Yum_Settings],
    }]],
    apt => Optional[Struct[{
      enable => Boolean,
      all    => Optional[Repository::Mirrors::Apt_Settings],
      jammy  => Optional[Repository::Mirrors::Apt_Settings],
      noble  => Optional[Repository::Mirrors::Apt_Settings],
      focal  => Optional[Repository::Mirrors::Apt_Settings],
    }]],
  }]
]
