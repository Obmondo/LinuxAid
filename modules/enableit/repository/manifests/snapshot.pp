# Snapshot
class repository::snapshot (
  Boolean         $enable = $repository::mirror::snapshot,
  Eit_types::User $user   = $repository::mirror::user,
) {

  # NOTE: Create snapshot on Saturday evening.
  common::systemd::timer { 'snapshot_repository':
    ensure  => ensure_present($enable),
    enable  => $enable,
    user    => $user,
    weekday => 'Sat',
    hour    => 1,
    command => '/usr/local/bin/snapshot_repo',
    require => Package['obmondo-repository-mirror'],
  }

}
