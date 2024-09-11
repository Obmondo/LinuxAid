#
# tmp_mounts.rb
#
# This fact provides information about /tmp, /var/tmp, and /dev/shm should they
# be present on the system.
#
# TODO: This should be completely replaced by this
# https://github.com/kwilczynski/facter-facts/blob/master/mounts.rb once Facter
# supports data structures and the code has been updated to capture all
# information. Yes, a lot of this is borrowed from there.
#
# Right now, this will return *three* facts based on each location and,
# unfortunately, you can't have symbols in fact names so we've substituted '/'
# with '_' and prepended 'tmp_mount'.
#
require 'facter'

target_dirs = %w(
  /tmp
  /var/tmp
  /dev/shm
)

mount_list = Hash.new

# Sometimes Ruby has issues with /proc
File.exist?('/proc/mounts') && Facter::Util::Resolution.exec('cat /proc/mounts 2> /dev/null').each_line do |line|
  line.strip!

  next if line.empty? or line.match(/^none/)

  mount = line.split(/\s+/)
  next unless target_dirs.include?(mount[1])

  # If there are multiple mounts at the same mountpoint, this picks up the very
  # last one, which is what you want.
  mount_list[mount[1]] = {
    :path   => mount[0],
    :fstype => mount[2],
    :opts   => mount[3].gsub(/'|"/,''),
    :freq   => mount[4],
    :passno => mount[5]
  }
end

# Check for bind mounts using findmnt since some systems (EL7) do not post the
# 'bind' keyword into the mount options any longer.
mount_list.keys.each do |mnt|
  findmnt_output = Facter::Util::Resolution.exec("findmnt #{mnt}")
  # on RHEL 5 the command "findmnt" doesn't exist, if it doesn't exist
  # then we just want to ignore this since there's nothing to do
  if findmnt_output
    mnt_source = findmnt_output.split("\n").last.split(/\s+/)[1]

    # We're a bind mount if this happens
    if mnt_source.include?('[')
      bind_source = mnt_source[/\[(.*)\]/,1] # Match contents in brackets, extract first match

      mount_list[mnt][:path] = bind_source
      mount_list[mnt][:fstype] = 'none'

      unless mount_list[mnt][:opts].split(',').include?('bind')
        mount_list[mnt][:opts] = mount_list[mnt][:opts] + ',bind'
      end
    end
  end
end

target_dirs.each do |dir|
  if mount_list[dir]
    Facter.add("tmp_mount#{dir.gsub('/','_')}") do
      confine :kernel => :linux
      setcode do
        mount_list[dir][:opts]
      end
    end

    Facter.add("tmp_mount_path#{dir.gsub('/','_')}") do
      confine :kernel => :linux
      setcode do
        mount_list[dir][:path]
      end
    end

    Facter.add("tmp_mount_fstype#{dir.gsub('/','_')}") do
      confine :kernel => :linux
      setcode do
        retval = mount_list[dir][:fstype]
      end
    end
  end
end
