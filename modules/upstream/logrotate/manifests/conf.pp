# Internal: Install and configure logrotate defaults file, usually
#   /etc/logrotate.conf
#
# see logrotate::Conf for description of options.
#
# Examples
#
#   logrotate::conf{'/etc/logrotate.conf':}
#
define logrotate::conf (
  Stdlib::Unixpath $path                             = $name,
  Enum['absent','present'] $ensure                   = 'present',
  Optional[Boolean] $compress                        = undef,
  Optional[String] $compresscmd                      = undef,
  Optional[String] $compressext                      = undef,
  Optional[String] $compressoptions                  = undef,
  Optional[Boolean] $copy                            = undef,
  Optional[Boolean] $copytruncate                    = undef,
  Boolean $create                                    = true,
  Optional[String] $create_mode                      = undef,
  Optional[String] $create_owner                     = undef,
  Optional[String] $create_group                     = undef,
  Optional[Boolean] $dateext                         = undef,
  Optional[String] $dateformat                       = undef,
  Optional[Boolean] $dateyesterday                   = undef,
  Optional[Boolean] $delaycompress                   = undef,
  Optional[String] $extension                        = undef,
  Optional[Boolean] $ifempty                         = undef,
  Optional[Variant[String,Boolean]] $mail            = undef,
  Optional[Enum['mailfirst', 'maillast']] $mail_when = undef,
  Optional[Integer] $maxage                          = undef,
  Optional[Logrotate::Size] $minsize                 = undef,
  Optional[Logrotate::Size] $maxsize                 = undef,
  Optional[Boolean] $missingok                       = undef,
  Optional[Variant[Boolean,String]] $olddir          = undef,
  Optional[String] $postrotate                       = undef,
  Optional[String] $prerotate                        = undef,
  Optional[String] $firstaction                      = undef,
  Optional[String] $lastaction                       = undef,
  Integer $rotate                                    = 4,
  Logrotate::Every $rotate_every                     = 'weekly',
  Optional[Logrotate::Size] $size                    = undef,
  Optional[Boolean] $sharedscripts                   = undef,
  Optional[Boolean] $shred                           = undef,
  Optional[Integer] $shredcycles                     = undef,
  Optional[Integer] $start                           = undef,
  Boolean $su                                        = false,
  String $su_user                                    = 'root',
  String $su_group                                   = 'root',
  Optional[String] $uncompresscmd                    = undef
) {
  case $mail {
    /\w+/: { $_mail = "mail ${mail}" }
    false: { $_mail = 'nomail' }
    default: {}
  }

  case $olddir {
    /\w+/: { $_olddir = "olddir ${olddir}" }
    false: { $_olddir = 'noolddir' }
    default: {}
  }

  if $rotate_every {
    $_rotate_every = $rotate_every ? {
      /ly$/   => $rotate_every,
      'day'   => 'daily',
      default => "${rotate_every}ly"
    }
  }

  if $create_group and !$create_owner {
    fail("Logrotate::Conf[${name}]: create_group requires create_owner")
  }

  if $create_owner and !$create_mode {
    fail("Logrotate::Conf[${name}]: create_owner requires create_mode")
  }

  if $create_mode and !$create {
    fail("Logrotate::Conf[${name}]: create_mode requires create")
  }

  #
  ####################################################################

  include logrotate

  $rules_configdir = $logrotate::rules_configdir

  file { $path:
    ensure  => $ensure,
    owner   => $logrotate::root_user,
    group   => $logrotate::root_group,
    mode    => $logrotate::logrotate_conf_mode,
    content => template('logrotate/etc/logrotate.conf.erb'),
  }

  if $logrotate::manage_package {
    Package[$logrotate::package] -> File[$path]
  }
}
