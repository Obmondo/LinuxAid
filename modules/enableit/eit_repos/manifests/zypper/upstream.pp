# Zypper upstream repos
class eit_repos::zypper::upstream (
  Boolean $ensure     = true,
  Boolean $noop_value = $eit_repos::noop_value,
) inherits eit_repos::zypper {

  case $facts['os']['name'] {
    'SLES': {
      $_suse_repo = lookup('eit_repos::upstream::repos').map |$repos| { "${repos}/${facts['os']['release']['full']}/${facts['os']['architecture']}" } #lint:ignore:140chars

      $suse_repo = $_suse_repo.join(' ')

      systemd::manage_unit { 'SUSE-Product.service':
        unit_entry    => {
          'Description' => 'SUSE-Product Enable Service',
        },
        service_entry => {
          'Type'            => 'oneshot',
          'ExecStart'       => "/bin/bash -c 'for product in ${suse_repo}; do /usr/bin/SUSEConnect --product \$product ; done'",
          'RemainAfterExit' => true,
        },
        install_entry => {
          'WantedBy' => 'multi-user.target',
        },
        enable        => false,
        active        => true,
      }
    }
    'openSUSE': {
      $repo_url = 'https://download.opensuse.org'
      $releasever = $facts['os']['release']['full']

      $repos = {
        'openh264'         => 'https://codecs.opensuse.org/openh264/openSUSE_Leap',
        'oss'              => "${repo_url}/distribution/leap/${releasever}/repo/oss",
        'non-oss'          => "${repo_url}/distribution/leap/${releasever}/repo/non-oss",
        'backports-update' => "${repo_url}/update/leap/${releasever}/backports",
        'update'           => "${repo_url}/update/leap/${releasever}/oss",
        'update-non-oss'   => "${repo_url}/update/leap/${releasever}/non-oss",
        'sle-update'       => "${repo_url}/update/leap/${releasever}/sle",
      }

      $repos.each | $key, $value | {
        zypprepo { "repo-${key}":
          ensure       => ensure_present($ensure),
          name         => "Repo-${key}",
          baseurl      => $value,
          enabled      => 1,
          autorefresh  => 1,
          type         => 'rpm-md',
          keeppackages => 0,
          gpgcheck     => 1,
          gpgkey       => "file:///usr/lib/rpm/gnupg/keys/${key}.gpg",
          noop         => $noop_value,
        }

        eit_repos::yum::gpgkey { $key :
          ensure     => ensure_present($ensure),
          path       => "/usr/lib/rpm/gnupg/keys/${key}.gpg",
          source     => "${value}/repodata/repomd.xml.key",
          noop_value => $noop_value,
        }
      }
    }
    default: {
      info { 'Unknown SLES OS': }
    }
  }
}
