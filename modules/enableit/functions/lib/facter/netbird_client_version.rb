# netbird_client_version returns a semver value based on the presence of netbird client
# on the host system 
Facter.add('netbird_client_version') do
  confine kernel: 'Linux'
  setcode do  
    # Only proceed if 'netbird' client is installed  
    if Facter::Core::Execution.which('netbird')
      # Execute the netbird version command and return the output
      Facter::Core::Execution.execute('netbird version').strip
    else
      nil
    end
  end
end
