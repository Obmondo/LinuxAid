# Set up a directory to download files to for testing
$tmp = $facts['os']['family'] ? {
  'windows' => 'C:/Temp',
  default   => '/tmp',
}

file { "${tmp}/remote_file":
  ensure => directory,
}

# Demonstrate a variety of file fetches
remote_file { 'now':
  ensure => present,
  path   => "${tmp}/remote_file/now",
  source => 'https://now.httpbin.org',
}

remote_file { "${tmp}/remote_file/basic-auth":
  ensure   => present,
  source   => 'https://httpbin.org/basic-auth/user1/passwd',
  username => 'user1',
  password => 'passwd',
}

remote_file { "${tmp}/remote_file/redirect":
  ensure => present,
  source => 'https://httpbin.org/redirect-to?url=http%3A%2F%2Fexample.com%2F',
}

remote_file { "${tmp}/remote_file/relative-redirect":
  ensure => present,
  source => 'https://httpbin.org/redirect/3',
}
