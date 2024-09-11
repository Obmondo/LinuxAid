Facter.add(:simplib__networkmanager) do
  confine :kernel => 'Linux'

  @nmcli_cmd = Facter::Util::Resolution.which('nmcli')
  confine { @nmcli_cmd }

  setcode do
    info = { 'enabled' => false }

    nmcli_cmd = @nmcli_cmd + ' -t'

    general_status = Facter::Core::Execution.execute(%(#{nmcli_cmd} -m multiline general status), :on_fail => :failed)
    unless general_status == :failed
      general_status = general_status.lines.map{|line| line.strip.split(':') }

      info['enabled'] = true
      info = {
        'general' => {
          'status' => Hash[general_status]
        }
      }
    end

    general_hostname = Facter::Core::Execution.execute(%{#{nmcli_cmd} general hostname}, :on_fail => :failed)
    unless general_hostname == :failed
      info['enabled'] = true
      info['general'] ||= {}
      info['general']['hostname'] = general_hostname.strip
    end

    connections = Facter::Core::Execution.execute(%(#{nmcli_cmd} connection show), :on_fail => :failed)
    unless connections == :failed
      info['enabled'] = true
      info['connection'] = {}

      connections.lines.each do |conn|
        name, uuid, type, device = conn.strip.split(':')

        info['connection'][device] = {
          'uuid' => uuid,
          'type' => type,
          'name' => name
        }
      end
    end

    info
  end
end
