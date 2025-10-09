# All discovered firewall capabilities
#
Facter.add('simplib__firewalls') do
  confine :kernel do |value|
    value.downcase != 'windows'
  end

  setcode do
    discovered_firewalls = []

    # A Hash of firewall commands to find.
    #
    # Useful for *nix hosts, Windows hosts will probably need to do something
    # different
    #
    # May want to split this up by target OS at some point
    firewall_metadata = {
      'firewalld' => nil,
      'iptables'  => nil,
      'ipfw'      => nil,
      'nft'       => nil,
      'pf'        => {
        command: 'pfctl',
      },
    }

    firewall_metadata.each do |fw_name, fw_opts|
      fw_cmd = fw_name

      if fw_opts && fw_opts[:command]
        fw_cmd = fw_opts[:command]
      end

      discovered_firewalls << fw_name if Facter::Util::Resolution.which(fw_cmd)
    end

    discovered_firewalls
  end
end
