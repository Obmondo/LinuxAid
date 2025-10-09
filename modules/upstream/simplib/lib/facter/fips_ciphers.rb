# List available FIPS-compatible OpenSSL ciphers on the system
# Returns: Array[String]
Facter.add('fips_ciphers') do
  confine kernel: 'Linux'
  openssl_bin = Facter::Core::Execution.which('openssl')

  setcode do
    Facter::Core::Execution.exec("#{openssl_bin} ciphers FIPS:-LOW").split(':') if openssl_bin
  end
end
