Facter.add(:simplib__networkmanager) do
  confine kernel: 'Linux'

  @nmcli_cmd = Facter::Util::Resolution.which('nmcli')
  confine { @nmcli_cmd }

  setcode do
    info = { 'enabled' => false }

    nmcli_cmd = @nmcli_cmd + ' -t'

    general_status = Puppet::Util::Execution.execute(%(#{nmcli_cmd} -m multiline general status))

    if general_status.exitstatus.zero?
      general_status = general_status.lines.map { |line| line.strip.split(':') }

      info['enabled'] = true
      info = {
        'general' => {
          'status' => Hash[general_status],
        },
      }
    end

    general_hostname = Puppet::Util::Execution.execute(%(#{nmcli_cmd} general hostname))

    if general_hostname.exitstatus.zero?
      info['enabled'] = true
      info['general'] ||= {}
      info['general']['hostname'] = general_hostname.strip
    end

    connections = Puppet::Util::Execution.execute(%(#{nmcli_cmd} connection show))

    if connections.exitstatus.zero?
      info['enabled'] = true
      info['connection'] = {}

      connections.lines.each do |conn|
        name, uuid, type, device = conn.strip.split(':')

        info['connection'][device] = {
          'uuid' => uuid,
          'type' => type,
          'name' => name,
        }
      end
    end

    info
  rescue => e
    Facter.warn(e)
  end
end
