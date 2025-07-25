# Return a list of all init systems present on the system.
Facter.add('init_systems') do
  setcode do
    init_systems = ['rc']

    if Facter::Util::Resolution.which('initctl')
      init_systems << 'upstart'
    end

    if Facter::Util::Resolution.which('systemctl')
      init_systems << 'systemd'
    end

    if Dir.exist?('/etc/init.d')
      init_systems << 'sysv'
    end

    init_systems
  end
end
