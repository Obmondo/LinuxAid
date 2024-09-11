require 'spec_helper_acceptance'

test_name 'auditd class with alternative auditd profiles'

# The fundamental module capabilities are tested in 00_base_spec.rb and
# 99_disable_audit_kernel_spec.rb.  The purpose of the tests in this
# file this is to verify each profile generates valid audit rules.
#
describe 'auditd class with alternative audit profiles' do
  require_relative('lib/util')

  let(:hieradata) {
    {
      'pki::cacerts_sources'    => ['file:///etc/pki/simp-testing/pki/cacerts'] ,
      'pki::private_key_source' => "file:///etc/pki/simp-testing/pki/private/%{fqdn}.pem",
      'pki::public_key_source'  => "file:///etc/pki/simp-testing/pki/public/%{fqdn}.pub",
    }
  }

  let(:simp_profile_aggressive) {
    {
      'auditd::root_audit_level' => 'aggressive',
    }.merge(hieradata)
  }

  let(:simp_profile_insane_enable_optional) {
    {
      'auditd::root_audit_level'                                 => 'insane',
      'auditd::config::audit_profiles::simp::audit_chmod'        => true,
      'auditd::config::audit_profiles::simp::audit_rename_remove'=> true,
      'auditd::config::audit_profiles::simp::audit_umask'        => true,
      'auditd::config::audit_profiles::simp::audit_selinux_cmds' => true,
      'auditd::config::audit_profiles::simp::audit_yum_cmd'      => true,
      'auditd::config::audit_profiles::simp::audit_rpm_cmd'      => true,
    }.merge(hieradata)
  }

  let(:stig_profile) {
    {
      'auditd::default_audit_profiles' => [ 'stig' ]
    }.merge(hieradata)
  }

  let(:simp_plus_stig_profiles) {
    {
      'auditd::default_audit_profiles' => [ 'simp', 'stig' ]
    }.merge(hieradata)
  }

  let(:manifest) {
    <<-EOS
      class { 'auditd': }
    EOS
  }

  hosts.each do |host|
    context "on #{host}" do

      context 'with simp profile, aggressive su-root auditing ' do
        it 'should work with no errors' do
          set_hieradata_on(host, simp_profile_aggressive)
          apply_manifest_on(host, manifest, :catch_failures => true)
        end

        it 'should be running the auditd service' do
          result = on(host, 'puppet resource service auditd')
          expect(result.output).to include("ensure => 'running'")
        end

        it 'should load valid rules' do
          # make sure the rules have been regenerated
          # (search for rule only contained in new rule set)
          retry_on(host, 'grep execve /etc/audit/audit.rules | grep renameat',
            { :max_retries => 30, :verbose => true })

          results = AuditdTestUtil::AuditdRules.new(host)

          expect(results.rules).to_not be_empty
          expect(results.warnings).to eq([])
          expect(results.errors).to eq([])
        end
      end

      context 'with simp profile, insane su-root auditing, all optional auditing enabled' do
        it 'should work with no errors' do
          set_hieradata_on(host, simp_profile_insane_enable_optional)
          apply_manifest_on(host, manifest, :catch_failures => true)
        end

        it 'should be running the auditd service' do
          result = on(host, 'puppet resource service auditd')
          expect(result.output).to include("ensure => 'running'")
        end


        it 'should load valid rules' do
          # make sure the rules have been regenerated
          # (search for tag only contained in new rule set)
          retry_on(host, 'grep package_changes /etc/audit/audit.rules',
            { :max_retries => 30, :verbose => true })


          results = AuditdTestUtil::AuditdRules.new(host)

          expect(results.rules).to_not be_empty
          expect(results.warnings).to eq([])
          expect(results.errors).to eq([])
        end
      end

      context 'with stig audit profile with default parameters' do
        it 'should work with no errors' do
          set_hieradata_on(host, stig_profile)
          apply_manifest_on(host, manifest, :catch_failures => true)
        end

        it 'should be running the auditd service' do
          result = on(host, 'puppet resource service auditd')
          expect(result.output).to include("ensure => 'running'")
        end

        it 'should load valid rules' do
          # make sure the rules have been regenerated
          # (search for tag only contained in new rule set)
          retry_on(host, 'cat /etc/audit/audit.rules | grep identity',
            { :max_retries => 30, :verbose => true })


          results = AuditdTestUtil::AuditdRules.new(host)

          expect(results.rules).to_not be_empty
          expect(results.warnings).to eq([])
          expect(results.errors).to eq([])
        end
      end

      context 'with simp + stig audit profiles, both with default parameters' do
        it 'should work with no errors' do
          set_hieradata_on(host, simp_plus_stig_profiles)
          apply_manifest_on(host, manifest, :catch_failures => true)
        end

        it 'should load valid rules' do
          # make sure the rules have been regenerated
          # (search for tag only contained in new rule set)
          retry_on(host, 'cat /etc/audit/audit.rules | grep su-root-activity',
            { :max_retries => 30, :verbose => true })

          results = AuditdTestUtil::AuditdRules.new(host)

          expect(results.rules).to_not be_empty
          expect(results.warnings).to eq([])
          expect(results.errors).to eq([])
        end
      end
    end
  end
end
