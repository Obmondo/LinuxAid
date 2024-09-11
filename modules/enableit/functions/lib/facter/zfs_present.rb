# Check if any partitions is a zfs member

Facter.add(:zfs_present) do
  setcode do
    !!Facter.value(:partitions).find do |(k, v)|
      v['filesystem'] == 'zfs_member'
    end
  end
end
