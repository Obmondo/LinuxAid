Facter.add(:simplib__networkmanager) do
  confine kernel: 'Linux'

  @nmcli_cmd = Facter::Core::Execution.which('nmcli')
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

      # nmcli escapes ':' as '\:' and '\' as '\\' in the values it prints in
      # terse tabular mode, so the fields cannot be split on every colon. A
      # lookbehind is not enough either: in 'foo\\:<uuid>:...' the colon really
      # is a separator, even though the character before it is a backslash.
      split_terse = ->(line) do
        fields = ['']
        escaped = false

        line.each_char do |char|
          if escaped
            fields[-1] += char
            escaped = false
          elsif char == '\\'
            escaped = true
          elsif char == ':'
            fields << ''
          else
            fields[-1] += char
          end
        end

        fields
      end

      connections.lines.each do |conn|
        name, uuid, type, device = split_terse.call(conn.chomp)

        # nmcli reports an empty device for a connection that is not active
        device = nil if device.nil? || device.empty?

        info['connection'][uuid] = {
          'device' => device,
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
