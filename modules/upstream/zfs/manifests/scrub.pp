# Set up a zpool scrub cron entry.
#
# @example Scrub a zpool once a month
#   include zfs
#
#   zfs::scrub { 'test':
#     hour     => '1',
#     minute   => '0',
#     month    => '*',
#     monthday => '1',
#     weekday  => '*',
#   }
#
# @param zpool The name of the zpool.
# @param hour See the `cron` resource type.
# @param minute See the `cron` resource type.
# @param month See the `cron` resource type.
# @param monthday See the `cron` resource type.
# @param weekday See the `cron` resource type.
# @param user See the `cron` resource type.
#
# @see puppet_classes::zfs zfs
#
# @since 2.2.0
define zfs::scrub (
  Any    $hour,
  Any    $minute,
  Any    $month,
  Any    $monthday,
  Any    $weekday,
  String $zpool    = $title,
  String $user     = 'root',
) {

  include zfs

  cron { "zpool scrub ${zpool}":
    command     => "zpool scrub ${zpool}",
    environment => "PATH=${facts['path']}",
    hour        => $hour,
    minute      => $minute,
    month       => $month,
    monthday    => $monthday,
    weekday     => $weekday,
    user        => $user,
  }
}
