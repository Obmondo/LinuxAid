# Check if user has set any confile
Facter.add("lxd_dnsmasq") do
  confine :kernel => :linux
  setcode do
    system("grep 'LXD_CONFILE=\"\"' /etc/default/lxd-bridge >/dev/null 2>&1")
    $?.exitstatus.zero?
  end
end
