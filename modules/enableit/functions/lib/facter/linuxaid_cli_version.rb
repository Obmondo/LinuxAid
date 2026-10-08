# linuxaid_cli_version returns a semver value based on the presence of linuxaid-cli
# on the host system
Facter.add('linuxaid_cli_version') do
  confine kernel: 'Linux'
  setcode do
    binary = '/opt/obmondo/bin/linuxaid-cli'
    if File.executable?(binary)
      output = Facter::Core::Execution.execute("#{binary} --version")
      if output =~ /v([0-9]+\.[0-9]+\.[0-9]+)/
        $1
      else
        nil
      end
    else
      nil
    end
  end
end
