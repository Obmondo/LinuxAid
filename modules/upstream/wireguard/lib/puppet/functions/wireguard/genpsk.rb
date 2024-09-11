Puppet::Functions.create_function(:'wireguard::genpsk') do
  # Returns string containing the wireguard psk for a certain interface.
  # @param name The interface name.
  # @param path Absolut path to the wireguard key files (default '/etc/wireguard').
  # @return [String] Returns psk.
  # @example Creating psk for the interface wg0.
  #   wireguard::genpsk('wg0') => 'FIVuvMyHvzujQweYa+oJdLDRvrpbHBithvMmNjN5rK4='
  dispatch :genpsk do
    required_param 'String', :name
    optional_param 'String', :path
    return_type 'String'
  end

  def genpsk(name, path='/etc/wireguard')
    psk_path = File.join(path, "#{name}.psk")
    raise Puppet::ParseError, "#{psk_path} is a directory" if File.directory?(psk_path)
    dir = File.dirname(psk_path)
    raise Puppet::ParseError, "#{dir} is not writable" if not File.writable?(dir)

    unless File.exists?(psk_path)
      psk = Puppet::Util::Execution.execute(
        ['/usr/bin/wg', 'genpsk'],
      )
      File.open(psk_path, 'w') do |f|
        f << psk
      end
    end
    File.read(psk_path)
  end
end

# vim: set ts=2 sw=2 :
