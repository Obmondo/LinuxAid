# Cloudflared yum repo (Cloudflare Tunnel)
class eit_repos::yum::cloudflared (
  Boolean               $ensure     = true,
  Eit_types::Noop_Value $noop_value = undef,
) {

  yumrepo { 'cloudflared-stable' :
    ensure   => ensure_present($ensure),
    baseurl  => 'https://pkg.cloudflare.com/cloudflared/rpm',
    enabled  => 1,
    noop     => $noop_value,
    gpgcheck => 1,
    descr    => 'cloudflared-stable',
    gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-cloudflare-main',
    target   => '/etc/yum.repos.d/cloudflared.repo',
  }

  eit_repos::yum::gpgkey { 'cloudflared-stable':
    ensure     => ensure_present($ensure),
    path       => '/etc/pki/rpm-gpg/RPM-GPG-KEY-cloudflare-main',
    source     => 'puppet:///modules/eit_repos/yum/RPM-GPG-KEY-cloudflare-main',
    noop_value => $noop_value,
  }
}
