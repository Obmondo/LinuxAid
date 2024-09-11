require 'spec_helper_acceptance'


# This set of tests should be last, so that we don't have to
# reboot the servers to get manifests to apply fully.
#
test_name 'disabling kernel auditing via auditd class'

describe 'auditd class with simp auditd profile' do
  let(:disable_hieradata) {
    {
      'pki::cacerts_sources'    => ['file:///etc/pki/simp-testing/pki/cacerts'] ,
      'pki::private_key_source' => "file:///etc/pki/simp-testing/pki/private/%{fqdn}.pem",
      'pki::public_key_source'  => "file:///etc/pki/simp-testing/pki/public/%{fqdn}.pub",
      'auditd::at_boot' => false
    }
  }

  let(:manifest) {
    <<-EOS
      class { 'auditd': }
    EOS
  }

  hosts.each do |host|
    context "on #{host}" do
      context 'disabling auditd at the kernel level' do
        it 'should work with no errors' do
          set_hieradata_on(host, disable_hieradata)
          apply_manifest_on(host, manifest, :catch_failures => true)
        end

        # Note: In SIMP, svckill will take care of actually disabling auditd if
        # it is no longer managed. Here, we're not including svckill by default.
        it 'should not kill the auditd service' do
          result = on(host, 'puppet resource service auditd')
          expect(result.output).to include("ensure => 'running'")
          expect(result.output).to include("enable => 'true'")
        end

        it 'should require reboot on subsequent run' do
          result = apply_manifest_on(host, manifest, :catch_failures => true)
          expect(result.output).to include('audit => modified')

          # Reboot to disable auditing in the kernel
          host.reboot
        end

        it 'should have kernel-level audit disabled on reboot' do
          retry_on(host, 'grep "audit=0" /proc/cmdline',
            { :max_retries => 30, :verbose => true }
          )
        end
      end
    end
  end
end
