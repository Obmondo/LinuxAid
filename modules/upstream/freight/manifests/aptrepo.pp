#
# == Class: freight::aptrepo
#
# Setup rcrowley's apt repository. This class depends on the "puppetlabs/apt" 
# puppet module:
#
# <https://forge.puppetlabs.com/puppetlabs/apt>
#
class freight::aptrepo inherits freight::params {

    include ::apt

    apt::source { 'freight-aptrepo':
        ensure   => 'present',
        location => 'http://build.openvpn.net/debian/freight_team',
        release  => $::lsbdistcodename,
        repos    => 'main',
        pin      => '501',
        key      => {
            'id'     => '30EBF4E73CCE63EEE124DD278E6DA8B4E158C569',
            'source' => 'https://swupdate.openvpn.net/repos/repo-public.gpg',
        },
    }
}
