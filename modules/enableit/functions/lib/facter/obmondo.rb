# Obmondo facter
Facter.add('obmondo') do
  setcode do
    obmondo = {}
    cert_path = Puppet.settings[:hostcert]
    if File.exist?(cert_path)
      cert = OpenSSL::X509::Certificate.new(File.read(cert_path))
      obmondo['certname'] = cert.subject.to_a.find { |name| name[0] == 'CN' }[1] rescue nil
    else
      nil
    end

    obmondo
  end
end
