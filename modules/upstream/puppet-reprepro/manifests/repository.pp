#
# Adds a packages repository.
#
# @param repo_name
#   the name of the repository
# @param ensure
#   present/absent, defaults to present
# @param incoming_name
#   the name of the rule-set, used as argument
# @param incoming_dir
#   the name of the directory to scan for .changes files
# @param incoming_tmpdir
#   directory where the files are copied into
#   before they are read
# @param incoming_allow
#   allowed distributions
# @param options
#   reprepro options
# @param createsymlinks
#   create suite symlinks
# @param documentroot
#   documentroot of the webserver (default undef)
#   if set, softlinks to the reprepro directories are made
#   the directory $documentroot must already exist
# @param max_files
#   maximum number of file resources created for recursion
#   see puppet file resource, available only on puppet > 7
# @param distributions
#   hash to define distributions in this repository
# @param distributions_defaults
#   defaults for all distributions in this repository
#
# @example
#   reprepro::repository { 'localpkgs':
#     ensure  => present,
#     options => ['verbose', 'basedir .'],
#   }
#
define reprepro::repository (
  String                 $repo_name              = $title,
  String                 $ensure                 = 'present',
  String                 $incoming_name          = 'incoming',
  String                 $incoming_dir           = 'incoming',
  String                 $incoming_tmpdir        = 'tmp',
  Variant[String, Array] $incoming_allow         = '',
  Array                  $options                = ['verbose', 'ask-passphrase', 'basedir .'],
  Boolean                $createsymlinks         = false,
  Optional[String]       $documentroot           = undef,
  Optional[Integer]      $max_files              = undef,
  Hash                   $distributions          = {},
  Hash                   $distributions_defaults = {},
) {

  include reprepro

  if $incoming_allow =~ Array {
    $_incoming_allow = $incoming_allow.join(' ')
  } else {
    $_incoming_allow = $incoming_allow
  }

  if $ensure == 'absent' {
    $directory_ensure = 'absent'
  } else {
    $directory_ensure = 'directory'
  }

  if $max_files {
    file { "${reprepro::basedir}/${repo_name}":
      ensure    => $directory_ensure,
      purge     => true,
      recurse   => true,
      force     => true,
      mode      => '2755',
      max_files => $max_files,
      owner     => $reprepro::user_name,
      group     => $reprepro::group_name,
    }
  } else {
    file { "${reprepro::basedir}/${repo_name}":
      ensure  => $directory_ensure,
      purge   => true,
      recurse => true,
      force   => true,
      mode    => '2755',
      owner   => $reprepro::user_name,
      group   => $reprepro::group_name,
    }
  }

  file {
    [ "${reprepro::basedir}/${repo_name}/dists",
      "${reprepro::basedir}/${repo_name}/pool",
      "${reprepro::basedir}/${repo_name}/conf",
      "${reprepro::basedir}/${repo_name}/lists",
      "${reprepro::basedir}/${repo_name}/db",
      "${reprepro::basedir}/${repo_name}/logs",
      "${reprepro::basedir}/${repo_name}/tmp",
    ]:
    ensure => $directory_ensure,
    mode   => '2755',
    owner  => $reprepro::user_name,
    group  => $reprepro::group_name,
  }

  file { "${reprepro::basedir}/${repo_name}/incoming":
    ensure => $directory_ensure,
    mode   => '2775',
    owner  => $reprepro::user_name,
    group  => $reprepro::group_name,
  }

  file { "${reprepro::basedir}/${repo_name}/conf/options":
    ensure  => $ensure,
    mode    => '0640',
    owner   => $reprepro::user_name,
    group   => $reprepro::group_name,
    content => inline_template("<%= @options.join(\"\n\") %>\n"),
  }

  file { "${reprepro::basedir}/${repo_name}/conf/incoming":
    ensure  => $ensure,
    mode    => '0640',
    owner   => $reprepro::user_name,
    group   => $reprepro::group_name,
    content => template('reprepro/incoming.erb'),
  }

  concat { "${reprepro::basedir}/${repo_name}/conf/distributions":
    ensure => $ensure,
    owner  => $reprepro::user_name,
    group  => $reprepro::group_name,
    mode   => '0640',
  }

  if $ensure == 'present' {
    concat::fragment { "00-distributions-${repo_name}":
      content => "# Puppet managed\n",
      target  => "${reprepro::basedir}/${repo_name}/conf/distributions",
    }
    concat::fragment { "00-update-${repo_name}":
      content => "# Puppet managed\n",
      target  => "${reprepro::basedir}/${repo_name}/conf/updates",
    }
    concat::fragment { "00-pulls-${repo_name}":
      content => "# Puppet managed\n",
      target  => "${reprepro::basedir}/${repo_name}/conf/pulls",
    }
    concat::fragment{"update-repositories add repository ${repo_name}":
      target  => "${reprepro::homedir}/bin/update-all-repositories.sh",
      content => "echo\necho 'updatating ${repo_name}:'\n/usr/bin/reprepro -b ${reprepro::basedir}/${repo_name} --noskipold update\n",
      order   => "50-${repo_name}",
    }
  }

  concat { "${reprepro::basedir}/${repo_name}/conf/updates":
    ensure => $ensure,
    owner  => $reprepro::user_name,
    group  => $reprepro::group_name,
    mode   => '0640',
  }

  concat {"${reprepro::basedir}/${repo_name}/conf/pulls":
    ensure => $ensure,
    owner  => root,
    group  => root,
    mode   => '0644',
  }


  if $createsymlinks {
    exec {"${repo_name}-createsymlinks":
      command     => "su -c 'reprepro -b ${reprepro::basedir}/${repo_name} --delete createsymlinks' ${reprepro::owner}",
      refreshonly => true,
      subscribe   => Concat[ "${reprepro::basedir}/${repo_name}/conf/distributions" ];
    }
  }

  if $documentroot {
    # create base-directory and symbolic link to repository for apache
    if $ensure == 'absent' {
      $link_ensure = 'absent'
    } else {
      $link_ensure = 'link'
    }
    file {"${documentroot}/${repo_name}":
      ensure  => $directory_ensure,
    }
    file {"${documentroot}/${repo_name}/dists":
      ensure => $link_ensure,
      target => "${reprepro::basedir}/${repo_name}/dists",
    }
    file {"${documentroot}/${repo_name}/pool":
      ensure => $link_ensure,
      target => "${reprepro::basedir}/${repo_name}/pool",
    }
  }

  create_resources('::reprepro::distribution', $distributions,
    $distributions_defaults + $reprepro::distributions_defaults + {repository => $repo_name}
  )
}
