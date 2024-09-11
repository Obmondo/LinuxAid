# Backup Push define
define common::backup::push (
  Eit_types::Host $target,
  Stdlib::Absolutepath $source,
  Stdlib::Absolutepath $destination,
  Pattern[/[0-9]+[DWMY]/] $keep_time,
  Integer[0,23] $hour,
  Optional[Eit_types::Email] $email = 'ops@obmondo.com',
  Array[Variant[
    Stdlib::Absolutepath,
    String]] $exclude                     = [],
) {

  # Make sure paths are absolute
  $_exclude_abs = $exclude.map |$x| {
    if $x =~ /^\// {
      $x
    } else {
      "${source}/${x}"
    }
  }

  # Create exclusion string
  $_exclude = $_exclude_abs.reduce('')|$acc, $x| {
    "${acc} --exclude '${x}'"
  }

  $_full_destination = "obmondo-backup@${target}::${destination}"
  $_command = "chronic rdiff-backup --verbosity 2 --exclude-device-files --exclude-sockets --exclude-other-filesystems ${_exclude} ::${source} ${_full_destination} && rdiff-backup --remove-older-than ${keep_time} --verbosity 2 ${_full_destination} | /usr/local/sbin/obmondofailure" #lint:ignore:140chars

  cron::daily { $title:
    minute      => fqdn_rand(60, $title),
    hour        => $hour,
    user        => 'root',
    command     => $_command,
    environment => [
      "MAILTO=${email}",
    ],
  }

}

# rdiff-backup -v2 --exclude-device-files --exclude-sockets --exclude-other-filesystems
