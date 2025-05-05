class { 'epel': }
-> class { 'apache': }
class { 'apache::mod::passenger': }
class { '::mysql::server': }
class { 'redmine': }
stdlib::ensure_packages(['wget'])
