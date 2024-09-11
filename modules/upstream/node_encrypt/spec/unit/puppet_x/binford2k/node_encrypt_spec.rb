require 'openssl'
require 'spec_helper'
require 'puppet_x/binford2k/node_encrypt'

ca_crt_pem = "-----BEGIN CERTIFICATE-----
MIIGGjCCBAKgAwIBAgIBATANBgkqhkiG9w0BAQsFADBaMVgwVgYDVQQDDE9QdXBw
ZXQgQ0EgZ2VuZXJhdGVkIG9uIHB1cHBldGZhY3RvcnkucHVwcGV0bGFicy52bSBh
dCAyMDE1LTEyLTExIDAxOjE5OjM2ICswMDAwMB4XDTE1MTIxMDAxMTkzN1oXDTIw
MTIwOTAxMTkzN1owWjFYMFYGA1UEAwxPUHVwcGV0IENBIGdlbmVyYXRlZCBvbiBw
dXBwZXRmYWN0b3J5LnB1cHBldGxhYnMudm0gYXQgMjAxNS0xMi0xMSAwMToxOToz
NiArMDAwMDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBALb54E3X2dFK
RCUuy5KQ+nEaNyAwZm5hLIiiUHAcBnXrxnPIrPU5Y0uW9wb8WgRC+o7rethpYYLb
1O7z4YqYPjniSUpUZ29gs4eee6ymtFLwW9P8LVUdXnWIiLTgk1Skojz/o2qqxUIl
dkoLHwcHcQyl5bIswjwsjSMxwfrEAtb89+vLZAELAUNWczxM3gbCYwQvNbwsjMni
RHiXQUccU/DRK3t2Kna+fRiA4jKlMqLFbJLjH/+76AzEUa88Fjz58ASCdU+izUdr
rPEzIk+QL+1Et6ltCvS+NZRpb622bqE6FeNRiTgCP3OlLCxjP+Bk1YsFt6PihIED
zlvEjJsM4JJwja60xrC4FBnwCn23IgxUZaXC1xFdDTlsm4JTtiJVt8NIUiBKdv6X
MUd2HxjV/9aXRCkK35Rz0Ee5SAqHcS1VPzwZDVYg3X44ijPXvLLgk+mOTD1+sL8V
XV2b4QTtpq9Tm4LG/N1ma49MzhUxAGKjRXR4ddRbCVaCqFRIRb+RKGvM53Pe2mPH
TDjr0rQJEIeHtsmWHP8PGCKAaJtwGnohcEcOVShCmnFEjL65Py3H8yYXFNHVfIz8
/Mziirt+r9U0lIpXA2EGPh7SNUBfa82CJIQalD1HOcTfKvet74MqjuYpHZiTxk0+
JoTGCS1ml7dBJ6HF2bbFfgQUbi6g44BpAgMBAAGjgeowgecwNwYJYIZIAYb4QgEN
BCoMKFB1cHBldCBSdWJ5L09wZW5TU0wgSW50ZXJuYWwgQ2VydGlmaWNhdGUwDgYD
VR0PAQH/BAQDAgEGMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFNaTc0999DiM
caJuuPPbcZ4HaXB7MGwGA1UdIwRlMGOhXqRcMFoxWDBWBgNVBAMMT1B1cHBldCBD
QSBnZW5lcmF0ZWQgb24gcHVwcGV0ZmFjdG9yeS5wdXBwZXRsYWJzLnZtIGF0IDIw
MTUtMTItMTEgMDE6MTk6MzYgKzAwMDCCAQEwDQYJKoZIhvcNAQELBQADggIBAHuU
o/qp+zD40vA/CiPZN+xA7yKcyoBpcmOULj9BSkeK855t3tFk6w2ie1/5/1naDZ0y
3XLwzKimJKDN45FHSh2FUAgn0BrQQTS0aVa/dao4zQi77B+uT13blnLRD45OAn1Y
tjaQ8gWw19pDbqs9emWvP4LzkHjvob8g8B+4+LE/llsmBvzKUy0eogaqz/0OCqTl
ks4qVWQOvOTfpIk/diG3VUfe2KxabN+OqjDMtdtnAbfkBl3z/GgSo/T58gKYn831
zx1MM+Zvh6N9B8FkzUX/c4PkaagwnZ7aT5LNYCM9BQTVChFMog4znI2u6mbMPEyy
XuLHXDiDSRuU4aqVpUASBXtFDhUCh8Z4K/FyLj9+e2iOdnrnbCqf1WUstsSFpASj
4SUnTFV0BkrlTP3wQc78KEXNMj4T18WcYpUxQNalkiCgphWh/fJSck7RtNJekY54
RZtdhpwDibSJM4TSWuF88cI37AunA9GJ+K4UuoBpkxM1ajJm294dM0XSO+Zos3v0
jIN1kdkbSsixdklUcLSUWUfjwx+4tZMbkntkkzn4xkx62537N+ZMwKxHgOIdR7jf
r6yO0dzizcnJeOP1gEgE96khTZgm47twK933P1eEz5BufyCG/p/oOTDFNNVmbIaL
YDzDZ+bYvR43pNB2D+mHscOqbM/jexf+jqitUimw
-----END CERTIFICATE-----"

ca_key_pem = "-----BEGIN RSA PRIVATE KEY-----
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
-----END RSA PRIVATE KEY-----"

cert_pem = "-----BEGIN CERTIFICATE-----
MIIGLzCCBBegAwIBAgIBAjANBgkqhkiG9w0BAQsFADBaMVgwVgYDVQQDDE9QdXBw
ZXQgQ0EgZ2VuZXJhdGVkIG9uIHB1cHBldGZhY3RvcnkucHVwcGV0bGFicy52bSBh
dCAyMDE1LTEyLTExIDAxOjE5OjM2ICswMDAwMB4XDTE1MTIxMDAxMTkzOVoXDTIw
MTIwOTAxMTkzOVowJjEkMCIGA1UEAwwbcHVwcGV0ZmFjdG9yeS5wdXBwZXRsYWJz
LnZtMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAnrTW7TQxW3u8+V1A
RFnsUZfSnpd8PiK8Q8kD56pw7Ttp68TSdmN4XwrCMvCgVQ3X/FQkcDkvzWfuDWX1
kp5xYjyuaS7UdRx07mlhfdyqeJr8UqeKjhZGCKl6PBDLqJWmEPaoF3e9St3nDxhW
vRy1xQ+0thOb8XoDqDXSMHPL19kBdk85CxLSkvDgeF8P4QZ1ovkYThxj/VF/La+2
LdOeQBOYC09u/ibs0lmBpjGdke9g4e4ACS5ZkTabcqNhMH7f/4qUBRqAGF5f0J2E
UgPB2pEjF8HiX/rYMIzgruKU552P1gTkCD1c1DhlBS2OiuM70pyfM47Zf1zAZRNl
HPoHGtVPMYIbKdZBWp7cTVP/ycBawsY1OkvS7zFrutGRaV5S/k0sQXuNvjI5FhJf
7qP5bwHxen/D5OKgz6bXWsG7uIhSak6tXNouLVtEkk+ka68gQXcqLRVLY8d8R7Rp
dfMGZjKEDFfZ8d2yhuiQiYAFbrnS0c9+CFPklwHQ80KWPUVzCktqzUqCXTABzr9d
R7G//kkPi5JaWOQMLMZpqm0wB4SozIDuiikgg6wN/t7uKLs+vpoMKDSt2tM7rfYq
VLB3F8QEvyA/+FH/KTPk4GPqP7aS5ZKNnrcwt3xPN46wi1E1JKkBpLaufbgnnwOi
3YdqJzZ4JgnBopNXzgKTzLvnOEcCAwEAAaOCATIwggEuMDcGCWCGSAGG+EIBDQQq
DChQdXBwZXQgUnVieS9PcGVuU1NMIEludGVybmFsIENlcnRpZmljYXRlMHMGA1Ud
EQRsMGqCCWxvY2FsaG9zdIIVbG9jYWxob3N0LmxvY2FsZG9tYWluggZwdXBwZXSC
EnB1cHBldC5sb2NhbGRvbWFpboINcHVwcGV0ZmFjdG9yeYIbcHVwcGV0ZmFjdG9y
eS5wdXBwZXRsYWJzLnZtMA4GA1UdDwEB/wQEAwIFoDAgBgNVHSUBAf8EFjAUBggr
BgEFBQcDAQYIKwYBBQUHAwIwDAYDVR0TAQH/BAIwADAdBgNVHQ4EFgQUWIs8UF7W
h4lVQr8AZ7qVG3CfKjEwHwYDVR0jBBgwFoAU1pNzT330OIxxom6489txngdpcHsw
DQYJKoZIhvcNAQELBQADggIBAGNa5Xy1mabPW7VleD1nqG0wXOsMR9IJsH8meG01
z3LXr1ij8z97GiZFbW8fAjor68SS6UIoyFFm36xkFqkBEdd+55YgD1Ejtnxp1XY8
2TtBBWH9PhL5QWipqkjO3Jpx5gMtn9xa4p9xtnGBk73/flT28ol0OuzxVIEOmMD1
Euk1Rnbcyu+dXyoKIRofx9b6qHi6h2Edx64rWLtls5oD3lBrgNx6+lhdBzNiNvre
d+berAj1e0s3I3gbzLPVLAz9Hf5uOG6SF6Sp9JZuCM9YA1h8cHtGq1giw74dq/FU
DGgNm1nanw7xf/6gRk7zI1WbPiI9R6NmrJYxDb9w2Ge8aPa7sd3vOvJU9brc2Zqc
Ca9uL7YsMofZLiNgaPN96FC6pYWMHC63eFzgLFc7YYeF700LfiJkubM43CcZYNYQ
dsMzMZdMPqnJCL82A3rFGRSuOq+faQm/DlmCi1tGDbbv3ZxqUKru+00xqbdYM59C
Y2bdDZbdefZMe5HMCJIjxEmxJ2ygvTIAi5cKpPqgjCPAK+imxKz+WI1ZWLEJYUJl
XvyrQt1p/+Y80zPXFnkb/MqsM6sk9t2A3mDZJxKLvBWZB8NngpKHMsWNv2qyiKg3
kDEjS7tgnIO8bfpXdRwPuk+dYGFLIafQSySfE096cTZ28zRobHuBekkPDBPD3iLU
Xsz6
-----END CERTIFICATE-----"

cert_key_pem = "-----BEGIN RSA PRIVATE KEY-----
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
-----END RSA PRIVATE KEY-----"

encrypted = "-----BEGIN PKCS7-----
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
uSI28VzZYavkITj+2D6tMys=
-----END PKCS7-----"

describe Puppet_X::Binford2k::NodeEncrypt do
  let(:node) { 'testhost.example.com' }

  it "should decrypt values which have been encrypted" do
    Puppet.settings.expects(:[]).twice.with(:hostcert).returns(
              '/etc/puppetlabs/puppet/ssl/certs/master.example.com.pem',   # encrypting for agent
              '/etc/puppetlabs/puppet/ssl/certs/testhost.example.com.pem'  # decrypting on agent
            )
    Puppet.settings.expects(:[]).twice.with(:hostprivkey).returns(
              '/etc/puppetlabs/puppet/ssl/private_keys/master.example.com.pem',  # encrypting for agent
              '/etc/puppetlabs/puppet/ssl/private_keys/testhost.example.com.pem' # decrypting on agent
            )
    Puppet.settings.expects(:[]).with(:signeddir).returns('/bad/path')                                 # fall through to certdir
    Puppet.settings.expects(:[]).with(:certdir).returns('/etc/puppetlabs/puppet/ssl/certs')            # encrypting for agent
    Puppet.settings.expects(:[]).with(:localcacert).returns('/etc/puppetlabs/puppet/ssl/certs/ca.pem') # decrypting as agent

    # encrypting on master for agent
    File.expects(:exist?).with(regexp_matches(/bad\/path\/testhost.example.com\.pem$/)).returns(nil)
    File.expects(:exist?).with(regexp_matches(/ssl\/certs\/testhost.example.com\.pem$/)).returns(true)

    File.expects(:read).with(regexp_matches(/ssl\/certs\/master.example.com\.pem$/)).returns(ca_crt_pem)
    File.expects(:read).with(regexp_matches(/ssl\/private_keys\/master.example.com\.pem$/)).returns(ca_key_pem)
    File.expects(:read).with(regexp_matches(/ssl\/certs\/testhost\.example\.com\.pem$/)).returns(cert_pem)

    # decrypting as agent
    File.expects(:read).with(regexp_matches(/certs\/testhost\.example\.com\.pem$/)).returns(cert_pem)
    File.expects(:read).with(regexp_matches(/private_keys\/testhost\.example\.com\.pem$/)).returns(cert_key_pem)
    File.expects(:read).with(regexp_matches(/certs\/ca\.pem$/)).returns(ca_crt_pem)

    data = Puppet_X::Binford2k::NodeEncrypt.encrypt('foo', 'testhost.example.com')
    expect(Puppet_X::Binford2k::NodeEncrypt.decrypt(data)).to eq 'foo'
  end

  it "should identify an encrypted string" do
    expect(Puppet_X::Binford2k::NodeEncrypt.encrypted?(encrypted) ).to be true
  end

  it "should identify a non-encrypted string" do
    expect(Puppet_X::Binford2k::NodeEncrypt.encrypted?('foo') ).to be false
  end
end

describe Puppet_X::Binford2k::NodeEncrypt::Value do

  it "should store a decrypted value" do
    File.expects(:read).with(regexp_matches(/certs\/testhost\.example\.com\.pem$/)).returns(cert_pem)
    File.expects(:read).with(regexp_matches(/private_keys\/testhost\.example\.com\.pem$/)).returns(cert_key_pem)
    File.expects(:read).with(regexp_matches(/certs\/ca\.pem$/)).returns(ca_crt_pem)

    # not sure why this isn't getting set automatically, but eh. This works
    Puppet.settings[:certname] = 'testhost.example.com'

    data = Puppet_X::Binford2k::NodeEncrypt::Value.new(encrypted)
    expect(data.decrypted_value).to eq 'foo'
  end

  it "should store a plain value" do
    data = Puppet_X::Binford2k::NodeEncrypt::Value.new('foo')
    expect(data.decrypted_value).to eq 'foo'
  end

  it "should complain about a non-string" do
    expect { Puppet_X::Binford2k::NodeEncrypt::Value.new(1234) }.to raise_error(ArgumentError)
  end

  it "should test equality" do
    first  = Puppet_X::Binford2k::NodeEncrypt::Value.new('foo')
    second = Puppet_X::Binford2k::NodeEncrypt::Value.new('foo')
    expect(first == second).to be true
  end

  it "should test inequality" do
    first  = Puppet_X::Binford2k::NodeEncrypt::Value.new('foo')
    second = Puppet_X::Binford2k::NodeEncrypt::Value.new('bar')
    expect(first == second).to be false
  end

end