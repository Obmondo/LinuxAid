class { 'epel': }
-> class { 'apache': }
class { 'apache::mod::passenger': }
class { '::mysql::server': }
class { 'redmine': }
ensure_packages(['wget'])
