require 'spec_helper'

# We have to test auditd::config::audit_profiles::stig via auditd,
# because auditd::config::audit_profiles::stig is private.  To take
# advantage of hooks built into puppet-rspec, the class described needs
# to be the class instantiated, i.e., auditd. Then, to adjust the
# private class's parameters, we will use hieradata.
describe 'auditd' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do

      let(:facts){ os_facts }

      it { is_expected.to compile.with_all_deps }

      context 'with auditd::config::audit_profile::stig default parameters' do
        let(:params) {{ :default_audit_profiles => ['stig'] }}

        it {
          if os_facts[:os][:release][:major] == '6'
            expected = File.read('spec/classes/config/audit_profiles/expected/stig_el6_base_rules.txt')
          else
            expected = File.read('spec/classes/config/audit_profiles/expected/stig_el7_base_rules.txt')
          end
          is_expected.to contain_file('/etc/audit/rules.d/50_00_stig_base.rules').with_content(expected)
        }
      end

      # check disabling of parameters for which the key is unique
      { 'access'                      => 'stig_audit_profile/disable__audit_unsuccessful_file_operations',
        'delete'                      => 'stig_audit_profile/disable__audit_rename_remove',
        'setuid/setgid'               => 'stig_audit_profile/disable__audit_suid_sgid',
        'module-change'               => 'stig_audit_profile/disable__audit_kernel_modules',
        'privileged-mount'            => 'stig_audit_profile/disable__audit_mount',
        'identity'                    => 'stig_audit_profile/disable__audit_local_account',
        'logins'                      => 'stig_audit_profile/disable__audit_login_files',
        'privileged-action'           => 'stig_audit_profile/disable__audit_cfg_sudoers',
        'privileged-passwd'           => 'stig_audit_profile/disable__audit_passwd_cmds',
        'privileged-postfix'          => 'stig_audit_profile/disable__audit_postfix_cmds',
        'privileged-ssh'              => 'stig_audit_profile/disable__audit_ssh_keysign_cmd',
        'privileged-cron'             => 'stig_audit_profile/disable__audit_crontab_cmd',
        'privileged-pam'              => 'stig_audit_profile/disable__audit_pam_timestamp_check_cmd',
      }.each do |key, hiera_file|
        context "with #{key} auditing disabled" do
          let(:params) {{ :default_audit_profiles => ['stig'] }}
          let(:hieradata) { hiera_file }

          it {
            is_expected.not_to contain_file('/etc/audit/rules.d/50_00_stig_base.rules').with_content(
              %r{^.* -k #{key}$}
            )
          }
        end
      end

      context 'with chown auditing disabled' do
        let(:params) {{ :default_audit_profiles => ['stig'] }}
        let(:hieradata) { 'stig_audit_profile/disable__audit_chown' }

        it {
          is_expected.not_to contain_file('/etc/audit/rules.d/50_00_stig_base.rules').with_content(
            %r(^-a exit,always -F arch=b\d\d -S \w*chown\w* -F auid>=\d+ -F auid!=4294967295 -k perm_mod$)
          )
        }
      end

      context 'with chmod auditing disabled' do
        let(:params) {{ :default_audit_profiles => ['stig'] }}
        let(:hieradata) { 'stig_audit_profile/disable__audit_chmod' }

        it {
          is_expected.not_to contain_file('/etc/audit/rules.d/50_00_stig_base.rules').with_content(
            %r(^-a exit,always -F arch=b\d\d -S \w*chmod\w* -F auid>=\d+ -F auid!=4294967295 -k perm_mod$)
          )
        }
      end

      context 'with attr auditing disabled' do
        let(:params) {{ :default_audit_profiles => ['stig'] }}
        let(:hieradata) { 'stig_audit_profile/disable__audit_attr' }

        it {
          is_expected.not_to contain_file('/etc/audit/rules.d/50_00_stig_base.rules').with_content(
            %r(^-a exit,always -F arch=b\d\d -S \w*attr -F auid>=\d+ -F auid!=4294967295 -k perm_mod$)
          )
        }
      end

      context 'with selinux command auditing disabled' do
        let(:params) {{ :default_audit_profiles => ['stig'] }}
        let(:hieradata) { 'stig_audit_profile/disable__audit_selinux_cmds' }

        it {
          is_expected.not_to contain_file('/etc/audit/rules.d/50_00_stig_base.rules').with_content(
            %r{^-a exit,always -F path=/usr/bin/(chcon|semanage|setsebool) -F perm=x -F auid>=\d+ -F auid!=4294967295 -k privileged-priv_change}
          )

          is_expected.not_to contain_file('/etc/audit/rules.d/50_00_stig_base.rules').with_content(
            %r(^-a exit,always -F path=/(usr/)?sbin/setfiles -F perm=x -F auid>=\d+ -F auid!=4294967295 -k privileged-priv_change)
          )
        }
      end

      context 'with privilege-related command auditing disabled' do
        let(:params) {{ :default_audit_profiles => ['stig'] }}
        let(:hieradata) { 'stig_audit_profile/disable__audit_priv_cmds' }
        [
          %r{^-a exit,always -F path=/(usr/)?bin/su -F perm=x -F auid>=\d+ -F auid!=4294967295 -k privileged-priv_change$},
          %r{^-a exit,always -F path=/usr/bin/sudo -F perm=x -F auid>=\d+ -F auid!=4294967295 -k privileged-priv_change$},
          %r{^-a exit,always -F path=/usr/bin/newgrp -F perm=x -F auid>=\d+ -F auid!=4294967295 -k privileged-priv_change$},
          %r{^-a exit,always -F path=/usr/bin/chsh -F perm=x -F auid>=\d+ -F auid!=4294967295 -k privileged-priv_change$},
          %r{^-a exit,always -F path=/(usr/)?bin/sudoedit -F perm=x -F auid>=\d+ -F auid!=4294967295 -k privileged-priv_change$}
        ].each do |command_regex|
          it {
            is_expected.not_to contain_file('/etc/audit/rules.d/50_00_stig_base.rules').
              with_content(command_regex)
          }
        end
      end

      context 'with all custom tags' do
        let(:params) {{ :default_audit_profiles => ['stig'] }}
        let(:hieradata) { 'stig_audit_profile/all_custom_tags' }

        it 'uses custom tags as rule keys' do
          if os_facts[:os][:release][:major] == '6'
            expected = File.read('spec/classes/config/audit_profiles/expected/stig_el6_all_custom_tags.txt')
          else
            expected = File.read('spec/classes/config/audit_profiles/expected/stig_el7_all_custom_tags.txt')
          end
          is_expected.to contain_file('/etc/audit/rules.d/50_00_stig_base.rules').with_content(expected)
        end
      end

      context 'with multiple audit profiles' do
        let(:params) {{ :default_audit_profiles => ['stig', 'simp'] }}

        it {
            if os_facts[:os][:release][:major] == '6'
              expected = File.read('spec/classes/config/audit_profiles/expected/stig_el6_base_rules.txt')
            else
              expected = File.read('spec/classes/config/audit_profiles/expected/stig_el7_base_rules.txt')
            end
            is_expected.to contain_file('/etc/audit/rules.d/50_00_stig_base.rules').with_content(expected)
        }

        it { is_expected.to contain_file('/etc/audit/rules.d/50_01_simp_base.rules').with_content(
          /#### auditd::config::audit_profiles::simp Audit Rules ####/)
        }
      end
    end
  end
end
