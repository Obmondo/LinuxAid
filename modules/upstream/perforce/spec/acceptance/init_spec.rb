# run a test task
require 'spec_helper_acceptance'

describe 'install and configure perforce' do
  let(:pp) do
    <<-MANIFEST
      $user = 'perforce'
      $service_root = '/opt/perforce/p4root'
      user { $user :
        ensure     => present,
        home       => $service_root,
        system     => true,
      }
      -> file { ['/opt/perforce', $service_root ] :
        ensure => directory,
        owner  => $user,
        mode   => '0750',
      }
      -> class { 'perforce': }
    MANIFEST
  end

  it 'applies with no errors' do
    apply_manifest(pp, catch_failures: true, debug: true)
  end

  it 'installs packages' do
    rpm_results = shell('rpm -qa | grep helix-p4d')
    expect(rpm_results.exit_code).to eq 0
  end

  describe service('p4d') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end

  it 'applies a second time without changes' do
    apply_manifest(pp, catch_changes: true)
  end

  context 'configure perforce with ssl' do
    let(:pp) do
      <<-MANIFEST
      $service_ssldir = "/opt/perforce/p4ssldir"
      $private_key = "-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDHYb8MmF7Bimo5
XubrQyTOcJmJORiK0eTbGJGm/nhTa4Kv1GB0+g+9+nSQwcxK3An+zMfwY7Ej269u
PwI+KlwtgvOCr22hQoO14KUHzqGAxjKB+vfLssMcaXs1mLndVmWJM9wVA9O1nzYs
iA6tfd0yOHUXxUqktTVB9JHGA5/6nQb63Snhk1rOHddSjDoO+iL6lmXZFG6x4IEq
odS1wG1MQueTB+KzgeT8m0JYX6uYx5KsmRKEO2l/YMLEOIj303NRIORUZU6OTUtP
Jx17ZdhDcm1Pn/6OlyqMuZqzJrYJIlJ7zsRWtzjP6XBKd3OrKLlyaGRThPUDGqKn
eM54KthDAgMBAAECggEBAIOjr8YbHATg5H14gTI3pKeAhH6rad7N8jIOKKx/Ouap
ByIcMItLRvWB1VB2A/IxEZBfmGrJB33LYCqEA3ET+sQ5v5k7RkDAb8G3zn43GT6y
nUpgbxbYsiWiJy0d5ymSD3vk95wQaMlzkwsX0ckOXur3h6foJP5WfhFL7qs0XX3S
4PALYbS//N2rKBk117Wnqiub0KjVjssWhICizZgvKJNET8//WoZ5TG51kp/mEgUY
XsrBgQa/hhYNGvBzUTJDafmRcnA9EDO4srr+iDDF2wbFgjSKUj5LBPEldbHtNg3i
UPlHODkUNYWla8CkaCvscXLk+G5KBueDdTBPyp0Cw7ECgYEA6jz9ZEL74uyFE+fT
3lCbj/nixRBiW5lCZ3bQT+fCe93ywmQpNNRI1HLijm2SSBQpC3baksJHxXHBXZW0
/4R1ETXpu2g6EIeB8zM0cs3VduRNG0QA0OsMnyWTJFwIONl1mD1f6ms0BWsbJbLr
9W0OQPwcIqDyg4s7hlrrVVhJo50CgYEA2ee/gXZl2yvYvnf5HPloB5IdEUX9lMRE
OMewiiu84e12N2dREAZp7Z8FMdT0fwixfBquWUa5E3LVEwGhheQ5pC+eUS3d7Mpi
Fv7qNg8o3oi1+B3jaaaKCk6zmPRbsxblF+PdUvds6pCCme4BXY8MD+OI4SKsENVf
B4u+wzpUVV8CgYAlFr0kh/qsRrkXmsiQVgEbvfxrKZn5WP4LteNsE41W4aDTqNph
dA+IHBzFYpIb+Z06JHqdbEfC+q0cbVz4bHfA3uGAfBNdlKc94+i1GORo6+NNouni
KqWX+XIf+raOkdgt3+H1Ez5scTYeNQNpm/f60DCARy2/KGencXP70nvufQKBgFEa
0gvUzrqSCl1yeDVRm2fd+ZW5UFYz6xSbNtlmyCnrYanjeaeWS40XOC7BDbPOv4jq
wWQXT8GuZyJo4/7a4J1839dlVAnTlkjq3q/6WoLhraFJNqDXTN/jRTO0GAGDjwei
V3mPAGoaGZJDpRx2ps2vKf5qElM9p94+JGWz6znPAoGBAIwLT8MEiUvLL87F4G1z
ImwI2+x3uJro6y977dax/20rjOa6TvGo4kIrVAgH7cjBVqzGvFFfGlQKytRJ9vDG
hkBHT7KEoypcPrbwu3fSStr/5qvq5mETOD3LAJsXC3kTa2mfmZii2KBQ0Fn7TOis
98tGyMeMVjTW2b6WqwW6DtA7
-----END PRIVATE KEY-----"
      $certificate = "-----BEGIN CERTIFICATE-----
MIIDXTCCAkWgAwIBAgIJAObn29SUorldMA0GCSqGSIb3DQEBCwUAMEUxCzAJBgNV
BAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBX
aWRnaXRzIFB0eSBMdGQwHhcNMTgwNTMwMjAwODEyWhcNMTkwNTMwMjAwODEyWjBF
MQswCQYDVQQGEwJBVTETMBEGA1UECAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50
ZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEAx2G/DJhewYpqOV7m60MkznCZiTkYitHk2xiRpv54U2uCr9RgdPoPvfp0
kMHMStwJ/szH8GOxI9uvbj8CPipcLYLzgq9toUKDteClB86hgMYygfr3y7LDHGl7
NZi53VZliTPcFQPTtZ82LIgOrX3dMjh1F8VKpLU1QfSRxgOf+p0G+t0p4ZNazh3X
Uow6Dvoi+pZl2RRuseCBKqHUtcBtTELnkwfis4Hk/JtCWF+rmMeSrJkShDtpf2DC
xDiI99NzUSDkVGVOjk1LTycde2XYQ3JtT5/+jpcqjLmasya2CSJSe87EVrc4z+lw
Sndzqyi5cmhkU4T1Axqip3jOeCrYQwIDAQABo1AwTjAdBgNVHQ4EFgQUB+oUrgz5
RiBnRE9hSjlS8pjGNb8wHwYDVR0jBBgwFoAUB+oUrgz5RiBnRE9hSjlS8pjGNb8w
DAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEAcvzyiNgYYRffoO5lzMjg
eOyO0F8+FZdZRDUwijAC8eRsBDD7vfJIhYdIp2wyqbLXFd4oA/8Lw4f92ETiUfdV
E7oG94dNzbk4sIZCtQWIiPiFeqEDGM+465goiuNeb+N0zHO5/4xO+tF8RW7MV2gc
ekQx4dzFV6CatsLkzQKMZHqDyRMXkebp36FdKmEbg/VH2P04JKIMQo0wc0L82dxn
SUSxBKdUCRIml+kXJZPE0CC+DtPcv1pzPAFLCDNQwdreurKk+KE985RKanx9iZdS
7RyghSDie7e/KhwfQjfreCUXSfV/3sAKajYv3LyWCc3WAE11Ugg8DUK+i55WikjC
WA==
-----END CERTIFICATE-----"
      file { $service_ssldir :
        ensure => directory,
        owner  => 'perforce',
        mode   => '0700',
      }
      -> file { "${service_ssldir}/privatekey.txt":
        ensure  => file,
        owner   => 'perforce',
        mode    => '0600',
        content => $private_key,
      }
      -> file {"${service_ssldir}/certificate.txt":
        ensure  => file,
        owner   => 'perforce',
        mode    => '0600',
        content => $certificate,
      }
      -> class { 'perforce':
        service_ssldir  => $service_ssldir
      }
      MANIFEST
    end

    it 'applies with no errors' do
      apply_manifest(pp, catch_failures: true)
    end

    describe service('p4d') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    it 'applies a second time without changes' do
      apply_manifest(pp, catch_changes: true)
    end
  end
end
