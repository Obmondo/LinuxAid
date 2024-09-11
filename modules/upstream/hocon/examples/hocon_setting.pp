hocon_setting { 'sample setting':
  ensure  => present,
  path    => '/tmp/foo.conf',
  setting => 'foo.foosetting',
  value   => 'FOO!',
}

hocon_setting { 'sample setting2':
  ensure  => present,
  path    => '/tmp/foo.conf',
  setting => 'bar.barsetting',
  value   => 'BAR!',
  require => Hocon_setting['sample setting'],
}

hocon_setting { 'sample setting3':
  ensure  => absent,
  path    => '/tmp/foo.conf',
  setting => 'bar.bazsetting',
  require => Hocon_setting['sample setting2'],
}
