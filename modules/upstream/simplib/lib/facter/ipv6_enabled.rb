# _Description_
#
# Return true if IPv6 is enabled and false if not.
#
# Reads the value directly from /proc/sys instead of shelling out to
# `sysctl`, so the fact has no dependency on the procps(-ng) package and
# degrades gracefully when IPv6 is unavailable.
#
Facter.add('ipv6_enabled') do
  confine kernel: 'Linux'
  setcode do
    # `disable_ipv6` is 0 when IPv6 is enabled. If the path does not exist,
    # IPv6 has been compiled out of the kernel, so it is not enabled.
    File.read('/proc/sys/net/ipv6/conf/all/disable_ipv6').strip == '0'
  rescue StandardError
    false
  end
end
