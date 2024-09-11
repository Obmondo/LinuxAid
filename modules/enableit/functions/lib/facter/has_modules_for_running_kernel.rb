Facter.add("has_modules_for_running_kernel") do
  confine :kernel => :linux
  setcode do
    kernelrelease = Facter.value(:kernelrelease)
    tmp = system "/bin/bash -c 'test -e /lib/modules/#{kernelrelease}/ >/dev/null'"
    $?.exitstatus == 0
  end
end
