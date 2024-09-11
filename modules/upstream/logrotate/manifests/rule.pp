# Public: Configure logrotate to rotate a logfile.
#
# namevar         - The String name of the rule.
# path            - The path String to the logfile(s) to be rotated.
# ensure          - The desired state of the logrotate rule as a String.  Valid
#                   values are 'absent' and 'present' (default: 'present').
# compress        - A Boolean value specifying whether the rotated logs should
#                   be compressed (optional).
# compresscmd     - The command String that should be executed to compress the
#                   rotated logs (optional).
# compressext     - The extention String to be appended to the rotated log files
#                   after they have been compressed (optional).
# compressoptions - A String of command line options to be passed to the
#                   compression program specified in `compresscmd` (optional).
# copy            - A Boolean specifying whether logrotate should just take a
#                   copy of the log file and not touch the original (optional).
# copytruncate    - A Boolean specifying whether logrotate should truncate the
#                   original log file after taking a copy (optional).
# create          - A Boolean specifying whether logrotate should create a new
#                   log file immediately after rotation (optional).
# create_mode     - An octal mode String logrotate should apply to the newly
#                   created log file if create => true (optional).
# create_owner    - A username String that logrotate should set the owner of the
#                   newly created log file to if create => true (optional).
# create_group    - A String group name that logrotate should apply to the newly
#                   created log file if create => true (optional).
# dateext         - A Boolean specifying whether rotated log files should be
#                   archived by adding a date extension rather just a number
#                   (optional).
# dateformat      - The format String to be used for `dateext` (optional).
#                   Valid specifiers are '%Y', '%m', '%d' and '%s'.
# dateyesterday   - A Boolean specifying whether to use yesterday's date instead
#                   of today's date to create the `dateext` extension (optional).
# delaycompress   - A Boolean specifying whether compression of the rotated
#                   log file should be delayed until the next logrotate run
#                   (optional).
# extension       - Log files with this extension String are allowed to keep it
#                   after rotation (optional).
# ifempty         - A Boolean specifying whether the log file should be rotated
#                   even if it is empty (optional).
# mail            - The email address String that logs that are about to be
#                   rotated out of existence are emailed to (optional).
# mailfirst       - A Boolean that when used with `mail` has logrotate email the
#                   just rotated file rather than the about to expire file
#                   (optional).
# maillast        - A Boolean that when used with `mail` has logrotate email the
#                   about to expire file rather than the just rotated file
#                   (optional).
# maxage          - The Integer maximum number of days that a rotated log file
#                   can stay on the system (optional).
# minsize         - The String minimum size a log file must be to be rotated,
#                   but not before the scheduled rotation time (optional).
#                   The default units are bytes, append k, M or G for kilobytes,
#                   megabytes and gigabytes respectively.
# maxsize         - The String maximum size a log file may be to be rotated;
#                   When maxsize is used, both the size and timestamp of a log
#                   file are considered for rotation.
#                   The default units are bytes, append k, M or G for kilobytes,
#                   megabytes and gigabytes respectively.
# missingok       - A Boolean specifying whether logrotate should ignore missing
#                   log files or issue an error (optional).
# olddir          - A String path to a directory that rotated logs should be
#                   moved to (optional).
# postrotate      - A command String or an Array of Strings that should be
#                   executed by /bin/sh after the log file is rotated
#                   optional).
# prerotate       - A command String or an Array of Strings that should be
#                   executed by /bin/sh before the log file is rotated and
#                   only if it will be rotated (optional).
# firstaction     - A command String or an Array of Strings that should be
#                   executed by /bin/sh once before all log files that match
#                   the wildcard pattern are rotated (optional).
# lastaction      - A command String or an Array of Strings that should be
#                   executed by /bin/sh once after all the log files that match
#                   the wildcard pattern are rotated (optional).
# rotate          - The Integer number of rotated log files to keep on disk
#                   (optional).
# rotate_every    - How often the log files should be rotated as a String.
#                   Valid values are 'day', 'week', 'month' and 'year'
#                   (optional).
# size            - The String size a log file has to reach before it will be
#                   rotated (optional).  The default units are bytes, append k,
#                   M or G for kilobytes, megabytes or gigabytes respectively.
# sharedscripts   - A Boolean specifying whether logrotate should run the
#                   postrotate and prerotate scripts for each matching file or
#                   just once (optional).
# shred           - A Boolean specifying whether logs should be deleted with
#                   shred instead of unlink (optional).
# shredcycles     - The Integer number of times shred should overwrite log files
#                   before unlinking them (optional).
# start           - The Integer number to be used as the base for the extensions
#                   appended to the rotated log files (optional).
# su              - A Boolean specifying whether logrotate should rotate under
#                   the specific su_user and su_group instead of the default.
#                   First available in logrotate 3.8.0.
# su_user         - A String username that logrotate should use to rotate a
#                   log file set instead of using the default if
#                   su => true (optional)
# su_group        - A String group name that logrotate should use to rotate a
#                   log file set instead of using the default if
#                   su => true (optional).
# uncompresscmd   - The String command to be used to uncompress log files
#                   (optional).
# custom_cfg      - Array of custom lines to be appended to the rules
#
# Examples
#
#   # Rotate /var/log/syslog daily and keep 7 days worth of compressed logs.
#   logrotate::rule { 'messages':
#     path         => '/var/log/messages',
#     copytruncate => true,
#     missingok    => true,
#     rotate_every => 'day',
#     rotate       => 7,
#     compress     => true,
#     ifempty      => true,
#   }
#
#   # Rotate /var/log/nginx/access_log weekly and keep 3 weeks of logs
#   logrotate::rule { 'nginx_access_log':
#     path         => '/var/log/nginx/access_log',
#     missingok    => true,
#     rotate_every => 'week',
#     rotate       => 3,
#     postrotate   => '/etc/init.d/nginx restart',
#   }
define logrotate::rule (
  Pattern[/^[a-zA-Z0-9\._-]+$/] $rulename           = $title,
  Enum['present','absent'] $ensure                  = 'present',
  Array[String[1]] $custom_cfg                      = [],
  Optional[Logrotate::Path] $path                   = undef,
  Optional[Boolean] $compress                       = undef,
  Optional[String] $compresscmd                     = undef,
  Optional[String] $compressext                     = undef,
  Optional[String] $compressoptions                 = undef,
  Optional[Boolean] $copy                           = undef,
  Optional[Boolean] $copytruncate                   = undef,
  Optional[Boolean] $create                         = undef,
  Optional[String] $create_mode                     = undef,
  Optional[String] $create_owner                    = undef,
  Optional[String] $create_group                    = undef,
  Optional[Boolean] $dateext                        = undef,
  Optional[String] $dateformat                      = undef,
  Optional[Boolean] $dateyesterday                  = undef,
  Optional[Boolean] $delaycompress                  = undef,
  Optional[String] $extension                       = undef,
  Optional[Boolean] $ifempty                        = undef,
  Optional[Variant[String,Boolean]] $mail           = undef,
  Optional[Enum['mailfirst','maillast']] $mail_when = undef,
  Optional[Integer] $maxage                         = undef,
  Optional[Logrotate::Size] $minsize                = undef,
  Optional[Logrotate::Size] $maxsize                = undef,
  Optional[Boolean] $missingok                      = undef,
  Optional[Variant[Boolean,String]] $olddir         = undef,
  Optional[Logrotate::Commands] $postrotate         = undef,
  Optional[Logrotate::Commands] $prerotate          = undef,
  Optional[Logrotate::Commands] $firstaction        = undef,
  Optional[Logrotate::Commands] $lastaction         = undef,
  Optional[Integer] $rotate                         = undef,
  Optional[Logrotate::Every] $rotate_every          = undef,
  Optional[Logrotate::Size] $size                   = undef,
  Optional[Boolean] $sharedscripts                  = undef,
  Optional[Boolean] $shred                          = undef,
  Optional[Integer] $shredcycles                    = undef,
  Optional[Integer] $start                          = undef,
  Boolean $su                                       = false,
  String $su_user                                   = 'root',
  String $su_group                                  = 'root',
  Optional[String] $uncompresscmd                   = undef
) {
  case $ensure {
    'present': {
      if $path == undef {
        fail("Logrotate::Rule[${rulename}]: path not specified")
      }
    }
    'absent': {}
    default: {
      fail("Logrotate::Rule[${rulename}]: invalid ensure value")
    }
  }

  case $mail {
    /\w+/: { $_mail = "mail ${mail}" }
    false: { $_mail = 'nomail' }
    default: {}
  }

  case $olddir {
    undef: {}
    false: { $_olddir = 'noolddir' }
    default: {
      $_olddir = "olddir ${olddir}"
    }
  }
  if $rotate_every {
    $_rotate_every = $rotate_every ? {
      /ly$/   => $rotate_every,
      'day'   => 'daily',
      default => "${rotate_every}ly"
    }
  }

  if ($create_group != undef) and ($create_owner == undef) {
    fail("Logrotate::Rule[${rulename}]: create_group requires create_owner")
  }

  if ($create_owner != undef) and ($create_mode == undef) {
    fail("Logrotate::Rule[${rulename}]: create_owner requires create_mode")
  }

  if ($create_mode != undef) and ($create != true) {
    fail("Logrotate::Rule[${rulename}]: create_mode requires create")
  }

  #############################################################################
  #

  include logrotate

  case $rotate_every {
    'hour', 'hourly': {
      include logrotate::hourly
      $rule_path = "${logrotate::rules_configdir}/hourly/${rulename}"

      file { "${logrotate::rules_configdir}/${rulename}":
        ensure => absent,
      }
    }
    default: {
      $rule_path = "${logrotate::rules_configdir}/${rulename}"

      file { "${logrotate::rules_configdir}/hourly/${rulename}":
        ensure => absent,
      }
    }
  }

  file { $rule_path:
    ensure  => $ensure,
    owner   => $logrotate::root_user,
    group   => $logrotate::root_group,
    mode    => $logrotate::logrotate_conf_mode,
    content => template('logrotate/etc/logrotate.d/rule.erb'),
    require => Class['logrotate::config'],
  }
}
