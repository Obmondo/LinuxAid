require 'spec_helper'

# We have to test auditd::config::audit_profiles::simp via auditd,
# because auditd::config::audit_profiles::simp is private.  To take
# advantage of hooks built into puppet-rspec, the class described needs
# to be the class instantiated, i.e., auditd. Then, to adjust the
# private class's parameters, we will use hieradata.
describe 'auditd' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do

      let(:facts){
        os_facts
      }

      it { is_expected.to compile.with_all_deps }

      context 'with default parameters' do

        it {
          if os_facts[:os][:release][:major] == '6'
            expected = File.read('spec/classes/config/audit_profiles/expected/simp_el6_basic_rules.txt')
          else
            expected = File.read('spec/classes/config/audit_profiles/expected/simp_el7_basic_rules.txt')
          end
          is_expected.to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').with_content(expected)
        }

        it 'specifies a key specified for each rule' do
          base_rules = catalogue.resource('File[/etc/audit/rules.d/50_00_simp_base.rules]')[:content].split("\n")

          rules_with_tags = base_rules.select{|x| x =~ / -k / }
          rules_with_tags.delete_if{|x| x =~ / -k \S+/}

          expect(rules_with_tags).to be_empty
        end

        it 'disables chmod auditing by default' do
          # chmod is disabled by default (SIMP-2250)
          is_expected.not_to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').with_content(
            %r(^-a exit,always -F arch=b\d\d -S chmod,fchmod,fchmodat -k chmod$)
          )
        end

        it 'disables rename/remove auditing by default' do
          is_expected.not_to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').with_content(
            %r(^-a exit,always -F arch=b\d\d -S rename,renameat,rmdir,unlink,unlinkat -F perm=x -k delete)
          )
        end

        it 'disables umask auditing by default' do
          is_expected.not_to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').with_content(
            %r(^-a exit,always -F arch=b\d\d -S umask -k umask)
          )
        end

        it 'disables package command auditing is disabled by default' do
          is_expected.not_to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').with_content(
            %r{^-w /(usr/)?bin/(rpm|yum) -p x}
          )

        end

        it 'disables selinux commands auditing by default' do
          is_expected.not_to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').with_content(
            %r{^-a exit,always -F path=/usr/bin/(chcon|semanage|setsebool) -F perm=x -k privileged-priv_change}
          )

          is_expected.not_to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').with_content(
            %r(^-a exit,always -F path=/(usr/)?sbin/setfiles -F perm=x -k privileged-priv_change)
          )
        end
      end

      context 'with root audit level set to aggressive' do
        let(:params) {{ :root_audit_level => 'aggressive' }}

        it {
          if os_facts[:os][:release][:major] == '6'
            expected = File.read('spec/classes/config/audit_profiles/expected/simp_el6_aggressive_rules.txt')
          else
            expected = File.read('spec/classes/config/audit_profiles/expected/simp_el7_aggressive_rules.txt')
          end
          is_expected.to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').with_content(expected)
        }
      end

      context 'with root audit level set to insane' do
        let(:params) {{ :root_audit_level => 'insane' }}

        it {
          if os_facts[:os][:release][:major] == '6'
            expected = File.read('spec/classes/config/audit_profiles/expected/simp_el6_insane_rules.txt')
          else
            expected = File.read('spec/classes/config/audit_profiles/expected/simp_el7_insane_rules.txt')
          end
          is_expected.to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').with_content(expected)
        }
      end

      # check disabling of parameters for which the key is unique
      { 'access'                      => 'disable__audit_unsuccessful_file_operations',
        'chown'                       => 'disable__audit_chown',
        'attr'                        => 'disable__audit_attr',
        'su-root-activity'            => 'disable__audit_su_root_activity',
        'suid-root-exec'              => 'disable__audit_suid_sgid',
        'modules'                     => 'disable__audit_kernel_modules',
        'audit_time_rules'            => 'disable__audit_time',
        'audit_network_modifications' => 'disable__audit_locale',
        'mount'                       => 'disable__audit_mount',
        'audit_account_changes'       => 'disable__audit_local_account',
        'MAC-policy'                  => 'disable__audit_selinux_policy',
        'logins'                      => 'disable__audit_login_files',
        'session'                     => 'disable__audit_session_files',
        'CFG_grub'                    => 'disable__audit_cfg_grub',
        'CFG_cron'                    => 'disable__audit_cfg_cron',
        'CFG_shell'                   => 'disable__audit_cfg_shell',
        'CFG_pam'                     => 'disable__audit_cfg_pam',
        'CFG_security'                => 'disable__audit_cfg_security',
        'CFG_services'                => 'disable__audit_cfg_services',
        'CFG_xinetd'                  => 'disable__audit_cfg_xinetd',
        'yum-config'                  => 'disable__audit_cfg_yum',
        'privileged-passwd'           => 'disable__audit_passwd_cmds',
        'privileged-postfix'          => 'disable__audit_postfix_cmds',
        'privileged-ssh'              => 'disable__audit_ssh_keysign_cmd',
        'privileged-cron'             => 'disable__audit_crontab_cmd',
        'privileged-pam'              => 'disable__audit_pam_timestamp_check_cmd',
      }.each do |key, hiera_file|
        context "with #{key} auditing disabled" do
          let(:hieradata) { "simp_audit_profile/#{hiera_file}" }

          it {
            is_expected.not_to contain_file('/etc/audit/rules.d/50_00)base.rules').with_content(
              %r{^.* -k #{key}$}
            )
          }
        end
      end

      context 'with privilege-related command auditing disabled' do
        let(:hieradata) { 'simp_audit_profile/disable__audit_priv_cmds' }
        [
          %r{^-a exit,always -F path=/(usr/)?bin/su -F perm=x -k privileged-priv_change$},
          %r{^-a exit,always -F path=/usr/bin/sudo -F perm=x -k privileged-priv_change$},
          %r{^-a exit,always -F path=/usr/bin/newgrp -F perm=x -k privileged-priv_change$},
          %r{^-a exit,always -F path=/usr/bin/chsh -F perm=x -k privileged-priv_change$},
          %r{^-a exit,always -F path=/(usr/)?bin/sudoedit -F perm=x -k privileged-priv_change$}
        ].each do |command_regex|
          it {
            is_expected.not_to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').
              with_content(command_regex)
          }
        end
      end

      context 'with sudoers config auditing disabled' do
        let(:hieradata) { 'simp_audit_profile/disable__audit_cfg_sudoers' }
        [
          %r{^-w /etc/sudoers -p wa -k CFG_sys$},
          %r{^-w /etc/sudoers.d/ -p wa -k CFG_sys$},
        ].each do |command_regex|
          it {
            is_expected.not_to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').
              with_content(command_regex)
          }
        end

      end

      context 'with other system config auditing disabled' do
        let(:hieradata) { 'simp_audit_profile/disable__audit_cfg_sys' }
        [
          %r{^-w /etc/default -p wa -k CFG_sys$},
          %r{^-w /etc/exports -p wa -k CFG_sys$},
          %r{^-w /etc/fstab -p wa -k CFG_sys$},
          %r{^-w /etc/host.conf -p wa -k CFG_sys$},
          %r{^-w /etc/hosts.allow -p wa -k CFG_sys$},
          %r{^-w /etc/hosts.deny -p wa -k CFG_sys$},
          %r{^-w /etc/initlog.conf -p wa -k CFG_sys$},
          %r{^-w /etc/inittab -p wa -k CFG_sys$},
          %r{^-w /etc/issue -p wa -k CFG_sys$},
          %r{^-w /etc/issue.net -p wa -k CFG_sys$},
          %r{^-w /etc/krb5.conf -p wa -k CFG_sys$},
          %r{^-w /etc/ld.so.conf -p wa -k CFG_sys$},
          %r{^-w /etc/ld.so.conf.d -p wa -k CFG_sys$},
          %r{^-w /etc/login.defs -p wa -k CFG_sys$},
          %r{^-w /etc/modprobe.conf.d -p wa -k CFG_sys$},
          %r{^-w /etc/modprobe.d/00_simp_blacklist.conf -p wa -k CFG_sys$},
          %r{^-w /etc/nsswitch.conf -p wa -k CFG_sys$},
          %r{^-w /etc/aliases -p wa -k CFG_sys$},
          %r{^-w /etc/at.deny -p wa -k CFG_sys$},
          %r{^-w /etc/rc.d/init.d -p wa -k CFG_sys$},
          %r{^-w /etc/rc.local -p wa -k CFG_sys$},
          %r{^-w /etc/rc.sysinit -p wa -k CFG_sys$},
          %r{^-w /etc/resolv.conf -p wa -k CFG_sys$},
          %r{^-w /etc/securetty -p wa -k CFG_sys$},
          %r{^-w /etc/snmp/snmpd.conf -p wa -k CFG_sys$},
          %r{^-w /etc/ssh/sshd_config -p wa -k CFG_sys$},
          %r{^-w /etc/sysconfig -p wa -k CFG_sys$},
          %r{^-w /etc/sysctl.conf -p wa -k CFG_sys$},
          %r{^-w /lib/firmware/microcode.dat -p wa -k CFG_sys$},
          %r{^-w /var/spool/at -p wa -k CFG_sys$},
        ].each do |command_regex|
          it {
            is_expected.not_to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').
              with_content(command_regex)
          }
        end
      end

      context 'with ptrace auditing disabled' do
        let(:hieradata) { 'simp_audit_profile/disable__audit_ptrace' }

        it {
          is_expected.not_to contain_file('/etc/audit/rules.d/50_00_simp_base.rules'). with_content(
            %r{^-a exit,always -F arch=b\d\d -S ptrace -k paranoid$}
          )
        }
      end

      context 'with personality auditing disabled' do
        let(:hieradata) { 'simp_audit_profile/disable__audit_personality' }

        it {
          is_expected.not_to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').with_content(
            %r{^-a exit,always -F arch=b\d\d -S personality -k paranoid$}
          )
        }
      end

      context 'with chmod auditing enabled' do
        let(:hieradata) { 'simp_audit_profile/enable__audit_chmod' }

        it {
          is_expected.to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').with_content(
            %r(^-a exit,always -F arch=b\d\d -S chmod,fchmod,fchmodat -k chmod$)
          )
        }
      end

      context 'with rename/remove operation auditing enabled' do
        let(:hieradata) { 'simp_audit_profile/enable__audit_rename_remove' }

        it {
          is_expected.to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').with_content(
            %r(^-a exit,always -F arch=b64 -S rename,renameat,rmdir,unlink,unlinkat -F perm=x -k delete)
          )
        }

        it {
          is_expected.to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').with_content(
            %r(^-a exit,always -F arch=b32 -S rename,renameat,rmdir,unlink,unlinkat -F perm=x -k delete)
          )
        }
      end

      context 'with umask operations auditing enabled' do
        let(:hieradata) { 'simp_audit_profile/enable__audit_umask' }

        it {
          is_expected.to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').with_content(
            %r(^-a exit,always -F arch=b\d\d -S umask -k umask)
          )
        }
      end

      context 'with selinux command auditing enabled' do
        let(:hieradata) { 'simp_audit_profile/enable__audit_selinux_cmds' }

        it {
          is_expected.to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').with_content(
            %r(^-a exit,always -F path=/usr/bin/chcon -F perm=x -k privileged-priv_change)
          )
        }

        it {
          is_expected.to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').with_content(
            %r(^-a exit,always -F path=/usr/sbin/semanage -F perm=x -k privileged-priv_change)
          )
        }

        it {
          is_expected.to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').with_content(
            %r(^-a exit,always -F path=/usr/sbin/setsebool -F perm=x -k privileged-priv_change)
          )
        }

        it {
          is_expected.to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').with_content(
            %r(^-a exit,always -F path=/(usr/)?sbin/setfiles -F perm=x -k privileged-priv_change)
          )
        }
      end

      context 'with yum command auditing enabled' do
        let(:hieradata) { 'simp_audit_profile/enable__audit_yum_cmd' }

        it {
          is_expected.to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').with_content(
            %r(^-w /(usr/)?bin/yum -p x)
          )
        }
      end

      context 'with rpm command auditing enabled' do
        let(:hieradata) { 'simp_audit_profile/enable__audit_rpm_cmd' }

        it {
          is_expected.to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').with_content(
            %r(^-w /(usr/)?bin/rpm -p x)
          )
        }
      end


      context 'with all auditing options enabled and custom tags' do
        let(:hieradata) { 'simp_audit_profile/enable_all_custom_tags' }
        let(:params) {{ :root_audit_level => 'insane' }}

        it 'uses custom tags as rule keys' do
          if os_facts[:os][:release][:major] == '6'
            expected = File.read('spec/classes/config/audit_profiles/expected/simp_el6_all_rules_custom_tags.txt')
          else
            expected = File.read('spec/classes/config/audit_profiles/expected/simp_el7_all_rules_custom_tags.txt')
          end
        end
      end

      context 'with multiple audit profiles' do
        let(:params) {{ :default_audit_profiles => ['simp', 'stig'] }}

        it {
            if os_facts[:os][:release][:major] == '6'
              expected = File.read('spec/classes/config/audit_profiles/expected/simp_el6_basic_rules.txt')
            else
              expected = File.read('spec/classes/config/audit_profiles/expected/simp_el7_basic_rules.txt')
            end
            is_expected.to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').with_content(expected)
        }

        it { is_expected.to contain_file('/etc/audit/rules.d/50_01_stig_base.rules').with_content(
          /#### auditd::config::audit_profiles::stig Audit Rules ####/)
        }
      end

      context 'with auditd version' do
        let(:auditd_conf) { catalogue.resource('File[/etc/audit/auditd.conf]') }

        # EL 6
        context '2.4.5' do
          let(:facts) {
            new_facts = Marshal.load(Marshal.dump(os_facts))
            new_facts[:auditd_version] = '2.4.5'

            new_facts
          }

          context 'default options' do
            it do
              expect(auditd_conf[:content]).to match(/log_format = RAW/)
              expect(auditd_conf[:content]).to_not match(/write_logs/)
            end
          end

          context 'write_logs = false' do
            let(:params) {{ :write_logs => false }}

            it do
              expect(auditd_conf[:content]).to match(/log_format = NOLOG/)
              expect(auditd_conf[:content]).to_not match(/write_logs/)
            end
          end

          context 'log_format = NOLOG' do
            let(:params) {{ :log_format => 'NOLOG' }}

            it do
              expect(auditd_conf[:content]).to match(/log_format = NOLOG/)
              expect(auditd_conf[:content]).to_not match(/write_logs/)
            end
          end

          context 'log_format = ENRICHED' do
            let(:params) {{ :log_format => 'ENRICHED' }}

            it do
              expect(auditd_conf[:content]).to match(/log_format = RAW/)
              expect(auditd_conf[:content]).to_not match(/write_logs/)
            end
          end
        end

        # EL 7.3
        context '2.6.5' do
          let(:facts) {
            new_facts = Marshal.load(Marshal.dump(os_facts))
            new_facts[:auditd_version] = '2.6.5'

            new_facts
          }

          context 'default options' do
            it do
              expect(auditd_conf[:content]).to match(/log_format = RAW/)
              expect(auditd_conf[:content]).to match(/write_logs = yes/)
            end
          end

          context 'write_logs = false' do
            let(:params) {{ :write_logs => false }}

            it do
              expect(auditd_conf[:content]).to match(/log_format = RAW/)
              expect(auditd_conf[:content]).to match(/write_logs = no/)
            end
          end

          context 'log_format = NOLOG' do
            let(:params) {{ :log_format => 'NOLOG' }}

            it do
              expect(auditd_conf[:content]).to match(/log_format = RAW/)
              expect(auditd_conf[:content]).to match(/write_logs = no/)
            end
          end

          context 'log_format = ENRICHED' do
            let(:params) {{ :log_format => 'ENRICHED' }}

            it do
              expect(auditd_conf[:content]).to match(/log_format = ENRICHED/)
              expect(auditd_conf[:content]).to match(/write_logs = yes/)
            end
          end
        end
      end

      context 'with deprecated parameters' do
        context 'disable audit_cfg_sudoers using deprecated audit_sudoers' do
          let(:hieradata) { 'simp_audit_profile/disable__audit_sudoers' }
          [
            %r{^-w /etc/sudoers -p wa -k CFG_sys$},
            %r{^-w /etc/sudoers.d/ -p wa -k CFG_sys$},
          ].each do |command_regex|
            it {
              is_expected.not_to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').
                with_content(command_regex)
            }
          end
        end

        context 'set audit_cfg_sudoers rule key using deprecated audit_sudoers_tag' do
          let(:hieradata) { 'simp_audit_profile/set__audit_sudoers_tag' }
          [
            %r{^-w /etc/sudoers -p wa -k old_sudoers_tag$},
            %r{^-w /etc/sudoers.d/ -p wa -k old_sudoers_tag$},
          ].each do |command_regex|
            it {
              is_expected.to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').
                with_content(command_regex)
            }
          end

          [
            %r{^-w /etc/sudoers -p wa -k CFG_sys$},
            %r{^-w /etc/sudoers.d/ -p wa -k CFG_sys$},
          ].each do |command_regex|
            it {
              is_expected.not_to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').
                with_content(command_regex)
            }
          end
        end

        context 'disable audit_cfg_grub using deprecated audit_grub' do
          let(:hieradata) { 'simp_audit_profile/disable__audit_grub' }
          it {
            is_expected.not_to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').with_content(
              %r{^.* -k CFG_grub$}
            )
          }
        end

        context 'set audit_cfg_grub rule key using deprecated audit_grub_tag' do
          let(:hieradata) { 'simp_audit_profile/set__audit_grub_tag' }

          it {
            is_expected.to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').with_content(
              %r{^.*grub.(d|conf).* -k old_grub_tag$}
            )
          }

          it {
            is_expected.not_to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').with_content(
              %r{^.* -k CFG_grub$}
            )
          }
        end

        context 'disable audit_cfg_yum using deprecated audit_yum' do
          let(:hieradata) { 'simp_audit_profile/disable__audit_yum' }
          it {
            is_expected.not_to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').with_content(
              %r{^.* -k yum_config$}
            )
          }
        end

        context 'set audit_cfg_yum rule key using deprecated audit_yum_tag' do
          let(:hieradata) { 'simp_audit_profile/set__audit_yum_tag' }

          it {
            is_expected.to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').with_content(
              %r{^.*/etc/yum.* -k old_yum_tag$}
            )
          }

          it {
            is_expected.not_to contain_file('/etc/audit/rules.d/50_00_simp_base.rules').with_content(
              %r{^.* -k yum_config$}
            )
          }
        end
      end
    end
  end
end
