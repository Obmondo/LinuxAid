# manage out mysql
class nftables::rules::out::mysql {
  nftables::rule {
    'default_out-mysql':
      content => 'tcp dport 3306 accept';
  }
}
