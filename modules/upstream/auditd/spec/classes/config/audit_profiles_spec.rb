require 'spec_helper'

# We have to test auditd::config::audit_profiles via auditd, because
# auditd::config::audit_profiles is private.  To take advantage of hooks
# built into puppet-rspec, the class described needs to be the class
# instantiated, i.e., auditd.
describe 'auditd' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts){
        _facts = Marshal.load(Marshal.dump(os_facts))
        unless _facts[:auditd_major_version]
          if _facts[:os][:release][:major] < '8'
            _facts[:auditd_major_version] = '2'
          else
            _facts[:auditd_major_version] = '3'
          end
        end

        _facts
      }

      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_auditd__rule('audit_auditd_config').with_content( %r(-w /var/log/audit -p wa -k audit-logs)) }

        it 'configures auditd to ignore rule failures' do
          is_expected.to contain_file('/etc/audit/rules.d/00_head.rules').with_content(%r(^-i$))
          is_expected.to contain_file('/etc/audit/rules.d/00_head.rules').with_content(%r(^-c$))
        end

        it 'configures buffer size' do
          is_expected.to contain_file('/etc/audit/rules.d/00_head.rules').with_content(
            %r(^-b\s+16384$)
          )
        end

        it 'configures failure mode' do
          is_expected.to contain_file('/etc/audit/rules.d/00_head.rules').with_content(
            %r(^-f\s+1$)
          )
        end

        it 'configures rate limiting' do
          is_expected.to contain_file('/etc/audit/rules.d/00_head.rules').with_content(
            %r(^-r\s+0$)
          )
        end

        it 'adds a drop rule to ignore anonymous and daemon events' do
          is_expected.to contain_file('/etc/audit/rules.d/05_default_drop.rules').with_content(
            %r(^-a\s+never,exit\s+-F\s+auid=-1$)
          )
        end

        it 'adds a rule to drop crond events' do
          is_expected.to contain_file('/etc/audit/rules.d/05_default_drop.rules').with_content(
            %r(^-a\s+never,user\s+-F\s+subj_type=crond_t$)
          )
        end

        it 'adds a rule to drop events from system services' do
          is_expected.to contain_file('/etc/audit/rules.d/05_default_drop.rules').with_content(
            %r(^-a\s+never,exit\s+-F\s+auid!=0\s+-F\s+auid<#{facts[:uid_min]}$)
          )
        end

        it { is_expected.to contain_class('auditd::config::audit_profiles::simp') }

      end

      context 'targeting specific SELinux types' do
        let(:params){{
          :target_selinux_types => ['unconfined_t', 'bob_t']
        }}

        it 'adds a rule to drop types not in the match list' do
          is_expected.to contain_file('/etc/audit/rules.d/05_default_drop.rules').with_content(
            %r(^-a\s+never,user\s+-F\s+subj_type!=unconfined_t$)
          )

          is_expected.to contain_file('/etc/audit/rules.d/05_default_drop.rules').with_content(
            %r(^-a\s+never,user\s+-F\s+subj_type!=bob_t$)
          )
        end
      end

      context 'setting the root audit level to aggressive' do
        let(:params) {{ :root_audit_level => 'aggressive' }}

        it { is_expected.to compile.with_all_deps }
        it 'increases the buffer size (above basic setting)' do
          is_expected.to contain_file('/etc/audit/rules.d/00_head.rules').with_content(
            %r(^-b\s+32788$)
          )
        end
      end

      context 'setting the root audit level to insane' do
        let(:params) {{ :root_audit_level => 'insane' }}

        it { is_expected.to compile.with_all_deps }
        it 'increases the buffer size (above aggressive setting)' do
          is_expected.to contain_file('/etc/audit/rules.d/00_head.rules').with_content(
            %r(^-b\s+65576$)
          )
        end
      end

      context "setting default_audit_profiles to ['stig']" do
        let(:params) {{ :default_audit_profiles => ['stig'] }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to_not contain_class('auditd::config::audit_profiles::simp') }
        it { is_expected.to contain_class('auditd::config::audit_profiles::stig') }
      end

      context "setting default_audit_profiles to ['simp', 'stig']" do
        let(:params) {{ :default_audit_profiles => ['simp', 'stig'] }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('auditd::config::audit_profiles::simp') }
        it { is_expected.to contain_class('auditd::config::audit_profiles::stig') }
      end

      context 'setting default_audit_profiles to []' do
        let(:params) {{ :default_audit_profiles => [] }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to_not contain_class('auditd::config::audit_profiles::simp') }
        it { is_expected.to_not contain_class('auditd::config::audit_profiles::stig') }
      end

    end
  end
end
