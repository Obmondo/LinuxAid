# DEPRECATED: This fact will be removed in the future
#
# This fact provides information about /tmp, /var/tmp, and /dev/shm should they
# be present on the system.
#
# Returns *three* facts based on each location.
#
# Since fact names cannot contain symbols, we've substituted '/' with '_' and
# prepended 'tmp_mount'.
#
# Please migrate to `simplib__mountpoints` when possible.
require 'facter'

simplib__tmp_mount_target_dirs = [
  '/tmp',
  '/var/tmp',
  '/dev/shm',
]

simplib__tmp_mount_list = nil

simplib__tmp_mount_target_dirs.each do |dir|
  Facter.add("tmp_mount#{dir.tr('/', '_')}") do
    confine kernel: :Linux
    confine { File.directory?(dir) }
    setcode do
      simplib__tmp_mount_list ||= Facter.value(:simplib__mountpoints)
      next unless simplib__tmp_mount_list[dir]
      simplib__tmp_mount_list[dir]['options'].join(',')
    end
  end

  Facter.add("tmp_mount_path#{dir.tr('/', '_')}") do
    confine kernel: :Linux
    confine { File.directory?(dir) }
    setcode do
      simplib__tmp_mount_list ||= Facter.value(:simplib__mountpoints)
      next unless simplib__tmp_mount_list[dir]
      simplib__tmp_mount_list[dir]['device']
    end
  end

  Facter.add("tmp_mount_fstype#{dir.tr('/', '_')}") do
    confine kernel: :Linux
    confine { File.directory?(dir) }
    setcode do
      simplib__tmp_mount_list ||= Facter.value(:simplib__mountpoints)
      next unless simplib__tmp_mount_list[dir]
      simplib__tmp_mount_list[dir]['filesystem']
    end
  end
end
