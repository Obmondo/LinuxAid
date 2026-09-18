# = Fact - Shmall =
#
# Return the value of kernel.shmall.
#
# Reads the value directly from /proc/sys instead of shelling out to
# `sysctl`, so the fact has no dependency on the procps(-ng) package and
# returns nil (rather than erroring) when the value is unavailable.
#
Facter.add('shmall') do
  confine kernel: 'Linux'
  setcode do
    File.read('/proc/sys/kernel/shmall').strip
  rescue StandardError
    nil
  end
end
