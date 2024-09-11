# Kolab repo
class kolab::repo {
  yumrepo { 'kolab':
    baseurl  => 'http://obs.kolabsys.com/repositories/Kolab:/16/CentOS_7/',
    enabled  => 1,
    gpgcheck => 1,
    gpgkey   => 'https://ssl.kolabsys.com/community.asc',
    descr    => 'Kolab 16: Stable Release (CentOS_7)',
    priority => '60',
  }

  # Import the gpgkey
  exec { 'Import gpgkey for kolab' :
    command => '/usr/bin/rpm --import https://ssl.kolabsys.com/community.asc',
    unless  => '/usr/bin/rpm -qa gpg-pubkey --qf "%{version}-%{release} %{summary}\n" | grep -i kolab >/dev/null',
    require => Yumrepo['kolab'],
  }
}
