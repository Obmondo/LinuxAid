# List available FIPS-compatible OpenSSL ciphers on the system
# Excludes weak ciphers vulnerable to CVE-2016-2183 (SWEET32)
# Returns: Array[String]
Facter.add('fips_ciphers') do
  confine kernel: 'Linux'
  openssl_bin = Facter::Core::Execution.which('openssl')

  setcode do
    # Exclude 3DES and other weak ciphers:
    # - 3DES (vulnerable to SWEET32/CVE-2016-2183)
    # - LOW (weak encryption)
    # - NULL (no encryption)
    # - EXPORT (weak export-grade)
    # - anon (anonymous, no authentication)
    Facter::Core::Execution.exec("#{openssl_bin} ciphers 'FIPS:-3DES:-LOW:-NULL:-EXPORT:-aNULL'").split(':') if openssl_bin
  end
end
