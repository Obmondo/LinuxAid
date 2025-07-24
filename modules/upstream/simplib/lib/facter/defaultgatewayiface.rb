# _Description_
#
# Return the default IPv4 gw interface of the system.
#
Facter.add(:defaultgatewayiface) do
  confine kernel: 'Linux'

  setcode do
    gw_iface = 'unknown'
    ip_cmd = Facter::Util::Resolution.which('ip')
    if ip_cmd
      route_lines = Facter::Core::Execution.exec("#{ip_cmd} route").split("\n")
      gw_lines = route_lines.delete_if { |line| !line.match(%r{^default\s+via\s+}) }
      unless gw_lines.empty?
        match = gw_lines.last.match(%r{\s+dev\s+(\S+)})
        if match
          gw_iface = match[1]
        end
      end
    end
    gw_iface
  end
end
