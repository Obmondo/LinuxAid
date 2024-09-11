class { 'vagrant::user':
  ensure      => present,
  user_name   => 'foobar_user',
  group_name  => 'foobar_group'
}

file { '/tmp/teardown.sh':
  ensure  => file,
  mode    => '0755',
  content => "#!/bin/bash
puppet apply --modulepath ${settings::modulepath} -e \"class {'vagrant::user': ensure => absent, user_name => 'foobar_user', group_name => 'foobar_group'}\"
"
}
