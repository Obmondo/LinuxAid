# netbird_client_version returns a semver value based on the presence of netbird client
# on the host system 
Facter.add('netbird_client_version') do
  setcode do

    # Only proceed further if the following conditions are met
    confine kernel: :linux
    confine { Facter::Core::Execution.which('netbird') }

    # Execute the 'netbird status' command and check if there's an output
    Facter::Core::Execution.execute('netbird version').strip

  end
end
