# Return a list of all init systems present on the system.
Facter.add("init_systems") do
  setcode do
    init_systems = ['rc']

    if Facter::Util::Resolution.which('initctl') then
      init_systems << 'upstart'
    end

    if Facter::Util::Resolution.which('systemctl') then
      init_systems << 'systemd'
    end

    if File.directory?('/etc/init.d') then
      init_systems << 'sysv'
    end
  end
end
