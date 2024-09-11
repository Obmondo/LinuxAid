# NetBackup OS tuning
class netbackup::server::tune (
  $sizedatabuffers_path         = '/usr/openv/netbackup/db/config/SIZE_DATA_BUFFERS',
  $sizedatabuffers              = '262144',
  $numberdatabuffers_path       = '/usr/openv/netbackup/db/config/NUMBER_DATA_BUFFERS',
  $numberdatabuffers            = '256',
  $sizedatabuffersdisk_path     = '/usr/openv/netbackup/db/config/SIZE_DATA_BUFFERS_DISK',
  $sizedatabuffersdisk          = '1048576',
  $numberdatabuffersdisk_path   = '/usr/openv/netbackup/db/config/NUMBER_DATA_BUFFERS_DISK',
  $numberdatabuffersdisk        = '512',
  $sizedatabuffersft_path       = '/usr/openv/netbackup/db/config/SIZE_DATA_BUFFERS_FT',
  $sizedatabuffersft            = '262144',
  $numberdatabuffersft_path     = '/usr/openv/netbackup/db/config/NUMBER_DATA_BUFFERS_FT',
  $numberdatabuffersft          = '16',
  $cdnumberdatabuffers_path     = '/usr/openv/netbackup/db/config/CD_NUMBER_DATA_BUFFERS',
  $cdnumberdatabuffers          = '128',
  $cdsizedatabuffers_path       = '/usr/openv/netbackup/db/config/CD_SIZE_DATA_BUFFERS',
  $cdsizedatabuffers            = '524288',
  $cdwholeimagecopy_path        = '/usr/openv/netbackup/db/config/CD_WHOLE_IMAGE_COPY',
  $cdwholeimagecopy             = true,
  $cdupdateinterval_path        = '/usr/openv/netbackup/db/config/CD_UPDATE_INTERVAL',
  $cdupdateinterval             = '180',
  $ostcdbusyretrylimit_path     = '/usr/openv/netbackup/db/config/OST_CD_BUSY_RETRY_LIMIT',
  $ostcdbusyretrylimit          = '1500',
  $netbuffersz_path             = '/usr/openv/netbackup/NET_BUFFER_SZ',
  $netbuffersz                  = '0',
  $netbufferszrest_path         = '/usr/openv/netbackup/NET_BUFFER_SZ_REST',
  $netbufferszrest              = '0',
  $dpsproxydefaultrecvtmo_path  = '/usr/openv/netbackup/db/config/DPS_PROXYDEFAULTRECVTMO',
  $dpsproxydefaultrecvtmo       = '3600',
  $dpsproxydefaultsendtmo_path  = '/usr/openv/netbackup/db/config/DPS_PROXYDEFAULTSENDTMO',
  $dpsproxydefaultsendtmo       = '3600',
  $dpsproxynoexpire_path        = '/usr/openv/netbackup/db/config/DPS_PROXYNOEXPIRE',
  $dpsproxynoexpire             = true,
  $maxentriesperadd_path        = '/usr/openv/netbackup/db/config/MAX_ENTRIES_PER_ADD',
  $maxentriesperadd             = '50000',
  $parentdelay_path             = '/usr/openv/netbackup/db/config/PARENT_DELAY',
  $parentdelay                  = true,
  $childdelay_path              = '/usr/openv/netbackup/db/config/CHILD_DELAY',
  $childdelay                   = true,
  $fbureadblks_path             = '/usr/openv/netbackup/FBU_READBLKS',
  $fbureadblks                  = '512 128',
) {

  file { $sizedatabuffers_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $sizedatabuffers,
  }

  file { $numberdatabuffers_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $numberdatabuffers,
  }

  file { $sizedatabuffersdisk_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $sizedatabuffersdisk,
  }

  file { $numberdatabuffersdisk_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $numberdatabuffersdisk,
  }

  file { $sizedatabuffersft_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $sizedatabuffersft,
  }

  file { $numberdatabuffersft_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $numberdatabuffersft,
  }

  file { $cdnumberdatabuffers_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $cdnumberdatabuffers,
  }

  file { $cdsizedatabuffers_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $cdsizedatabuffers,
  }

  $cdwholeimagecopy_enable = $cdwholeimagecopy ? {
    true    => 'present',
    false   => 'absent',
    default => 'present',
  }

  file { $cdwholeimagecopy_path:
    ensure => $cdwholeimagecopy_enable,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  file { $cdupdateinterval_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $cdupdateinterval,
  }

  file { $ostcdbusyretrylimit_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $ostcdbusyretrylimit,
  }

  file { $netbuffersz_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $netbuffersz,
  }

  file { $netbufferszrest_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $netbufferszrest,
  }

  file { $dpsproxydefaultrecvtmo_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $dpsproxydefaultrecvtmo,
  }

  file { $dpsproxydefaultsendtmo_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $dpsproxydefaultsendtmo,
  }

  $dpsproxynoexpire_enable = $dpsproxynoexpire ? {
    true    => 'present',
    false   => 'absent',
    default => 'present',
  }

  file { $dpsproxynoexpire_path:
    ensure => $dpsproxynoexpire_enable,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  file { $maxentriesperadd_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $maxentriesperadd,
  }

  $parentdelay_enable = $parentdelay ? {
    true    => 'present',
    false   => 'absent',
    default => 'present',
  }

  file { $parentdelay_path:
    ensure => $parentdelay_enable,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  $childdelay_enable = $childdelay ? {
    true    => 'present',
    false   => 'absent',
    default => 'present',
  }

  file { $childdelay_path:
    ensure => $childdelay_enable,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  file { $fbureadblks_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $fbureadblks,
  }

}
