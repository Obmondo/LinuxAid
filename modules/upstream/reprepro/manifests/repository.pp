# == Definition: reprepro::repository
#
#   Adds a packages repository.
#
# === Parameters
#
#   - *name*: the name of the repository
#   - *ensure*: present/absent, defaults to present
#   - *basedir*: base directory of reprepro
#   - *incoming_name*: the name of the rule-set, used as argument
#   - *incoming_dir*: the name of the directory to scan for .changes files
#   - *incoming_tmpdir*: directory where the files are copied into
#                        before they are read
#   - *incoming_allow*: allowed distributions
#   - *owner*: owner of reprepro files
#   - *group*: reprepro files group
#   - *options*: reprepro options
#   - *createsymlinks*: create suite symlinks
#
# === Requires
#
#   - Class["reprepro"]
#
# === Example
#
#   reprepro::repository { 'localpkgs':
#     ensure  => present,
#     options => ['verbose', 'basedir .'],
#   }
#
define reprepro::repository (
  $ensure          = present,
  $basedir         = $::reprepro::basedir,
  $incoming_name   = 'incoming',
  $incoming_dir    = 'incoming',
  $incoming_tmpdir = 'tmp',
  $incoming_allow  = '',
  $owner           = 'reprepro',
  $group           = 'reprepro',
  $options         = ['verbose', 'ask-passphrase', 'basedir .'],
  $createsymlinks  = false,
  ) {

  include reprepro::params
  include concat::setup

  file { "${basedir}/${name}":
    ensure  => $ensure ? { 'present' => 'directory', default => $ensure,},
    purge   => $ensure ? { 'present' => undef,     default => true,},
    recurse => $ensure ? { 'present' => undef,     default => true,},
    force   => $ensure ? { 'present' => undef,     default => true,},
    mode    => '2755',
    owner   => $owner,
    group   => $group,
  }

  file { "${basedir}/${name}/dists":
    ensure  => directory,
    mode    => '2755',
    owner   => $owner,
    group   => $group,
    require => File["${basedir}/${name}"],
  }

  file { "${basedir}/${name}/pool":
    ensure  => directory,
    mode    => '2755',
    owner   => $owner,
    group   => $group,
    require => File["${basedir}/${name}"],
  }

  file { "${basedir}/${name}/conf":
    ensure  => directory,
    mode    => '2755',
    owner   => $owner,
    group   => $group,
    require => File["${basedir}/${name}"],
  }

  file { "${basedir}/${name}/lists":
    ensure  => directory,
    mode    => '2755',
    owner   => $owner,
    group   => $group,
    require => File["${basedir}/${name}"],
  }

  file { "${basedir}/${name}/db":
    ensure  => directory,
    mode    => '2755',
    owner   => $owner,
    group   => $group,
    require => File["${basedir}/${name}"],
  }

  file { "${basedir}/${name}/logs":
    ensure  => directory,
    mode    => '2755',
    owner   => $owner,
    group   => $group,
    require => File["${basedir}/${name}"],
  }

  file { "${basedir}/${name}/tmp":
    ensure  => directory,
    mode    => '2755',
    owner   => $owner,
    group   => $group,
    require => File["${basedir}/${name}"],
  }

  file { "${basedir}/${name}/incoming":
    ensure  => directory,
    mode    => '2775',
    owner   => $owner,
    group   => $group,
    require => File["${basedir}/${name}"],
  }

  file { "${basedir}/${name}/conf/options":
    ensure  => $ensure,
    mode    => '0640',
    owner   => $owner,
    group   => $group,
    content => inline_template("<%= @options.join(\"\n\") %>\n"),
    require => File["${basedir}/${name}/conf"],
  }

  file { "${basedir}/${name}/conf/incoming":
    ensure  => $ensure,
    mode    => '0640',
    owner   => $owner,
    group   => $group,
    content => template('reprepro/incoming.erb'),
    require => File["${basedir}/${name}/conf"],
  }

  concat { "${basedir}/${name}/conf/distributions":
    owner   => $owner,
    group   => $group,
    mode    => '0640',
    require => File["${basedir}/${name}/conf"],
  }

  concat::fragment { "00-distributions-${name}":
    ensure  => $ensure,
    content => "# Puppet managed\n",
    target  => "${basedir}/${name}/conf/distributions",
  }

  concat { "${basedir}/${name}/conf/updates":
    owner   => $owner,
    group   => $group,
    mode    => '0640',
    force   => true, 
    require => File["${basedir}/${name}/conf"],
  }

  concat::fragment { "00-update-${name}":
    ensure  => $ensure,
    content => "# Puppet managed\n",
    target  => "${basedir}/${name}/conf/updates",
  }

  concat {"${basedir}/${name}/conf/pulls":
    owner   => root,
    group   => root,
    mode    => '0644',
    force   => true,
    require => File["${basedir}/${name}/conf"],
  }

  concat::fragment { "00-pulls-${name}":
    ensure  => $ensure,
    content => "# Puppet managed\n",
    target  => "${basedir}/${name}/conf/pulls",
  }

  if $createsymlinks {
    exec {"${name}-createsymlinks":
      command     => "su -c 'reprepro -b ${basedir}/${name}/${repository} --delete createsymlinks' ${owner}",
      refreshonly => true,
      subscribe   => File["${basedir}/${name}/conf/distributions"],
    }
  }
}
