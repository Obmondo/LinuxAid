# Return path of HPE ssacli/hpssacli binary
Facter.add(:hp_raid_cli) do
    confine :manufacturer => ['HP', 'HPE']
    confine :virtual      => 'physical'

    setcode do
      if exe = Facter::Core::Execution.which('ssacli') ||
                 Facter::Core::Execution.which('hpssacli')
        %x{readlink -f #{exe}}.strip
      end
    end
end
