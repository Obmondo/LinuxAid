# frozen_string_literal: true

Facter.add('zfs_zpool_cache_present') do
  confine kernel: 'Linux'
  setcode do
    File.exist?('/etc/zfs/zpool.cache')
  end
end

Facter.add('zfs_zpool_cache_present') do
  setcode do
    false
  end
end
