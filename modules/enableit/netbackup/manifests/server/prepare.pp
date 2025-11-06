# NetBackup limit/sysctl/selinux configuration
class netbackup::server::prepare {

  # START Pre-checks
  include limits
  limits::limits { 'netbackup_nofile':
    ensure     => present,
    user       => '*',
    limit_type => 'nofile',
    hard       => 65440,
    soft       => 8000,
  }

  sysctl { 'kernel.sem': value => '300  307200  32  1024', }
  sysctl { 'vm.dirty_background_ratio': value => '5', }
  sysctl { 'vm.dirty_ratio': value => '20', }
  sysctl { 'net.ipv4.tcp_window_scaling': value => '0', }
  sysctl { 'net.ipv4.conf.all.send_redirects': value => '0', }
  sysctl { 'net.ipv4.ipfrag_low_thresh': value => '524288', }
  sysctl { 'net.ipv4.ipfrag_high_thresh': value => '1048576', }
  sysctl { 'net.ipv4.tcp_tw_reuse': value => '1', }
  sysctl { 'net.ipv4.tcp_tw_recycle': value => '1', }
  sysctl { 'net.ipv4.tcp_max_syn_backlog': value => '4096', }
  sysctl { 'net.ipv4.tcp_syncookies': value => '0', }
  sysctl { 'net.ipv4.tcp_sack': value => '0', }
  sysctl { 'net.ipv4.tcp_dsack': value => '0', }
  sysctl { 'net.ipv4.tcp_keepalive_time': value => '510', }
  sysctl { 'net.ipv4.tcp_keepalive_probes': value => '3', }
  sysctl { 'net.ipv4.tcp_keepalive_intvl': value => '3', }
  sysctl { 'net.ipv4.icmp_echo_ignore_broadcasts': value => '1', }
  sysctl { 'net.ipv4.conf.all.rp_filter': value => '1', }

  class { 'selinux':
    mode => 'disabled',
  }
  # END Pre-checks

}
