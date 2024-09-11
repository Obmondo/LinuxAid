# _Description_
#
# Return the default IPv4 gateway of the system
#
Facter.add(:defaultgateway) do
  confine :kernel => 'Linux'

  setcode do
    gw = "unknown"
    ip_cmd = Facter::Util::Resolution.which('ip')
    if ip_cmd
      route_lines = Facter::Core::Execution.exec("#{ip_cmd} route").split("\n")
      gw_lines = route_lines.delete_if { |line| !line.match(/^default\s+via\s+/) }
      unless gw_lines.empty?
        match = gw_lines.last.match(/default\s+via\s+([0-9\.]*)\s+dev\s+/)
        if match
          gw = match[1]
        end
      end
    end
    gw
  end
end
