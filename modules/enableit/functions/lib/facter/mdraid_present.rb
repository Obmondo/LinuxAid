# Check if any partitions is a mdraid member
require 'pathname'

Facter.add(:mdraid_present) do
  confine :kernel => :linux

  setcode do
    if Pathname('/proc/mdstat').exist?
      open('/proc/mdstat').readlines.grep(/^md[0-9]+\s:/).count > 0
    end
  end
end
