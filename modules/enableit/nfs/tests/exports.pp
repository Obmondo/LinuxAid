# testing exports given directly

$test_exports =  {
    export_1 => { path => '/tmp/export_1',
      options => [ 'rw', 'async' ],
      clients => [ "${::network_eth0}/${netmask_eth0}" ],
    },

    export_chroot => { path => '/tmp/export_chroot',
      options => [ 'ro', 'async', 'no_subtree_check', 'no_root_squash' ],
      clients => [ '192.168.1.0/24' ],
    },
}

class { 'nfs::exports': definitions => $test_exports }
