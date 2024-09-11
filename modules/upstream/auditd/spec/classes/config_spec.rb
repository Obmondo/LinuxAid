require 'spec_helper'

# We have to test auditd::config via auditd, because auditd::config is
# private.  To take advantage of hooks built into puppet-rspec, the
# class described needs to be the class instantiated, i.e., auditd.
# This test also includes tests for private class auditd::config::logging

describe 'auditd' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let (:facts) {os_facts}

        context "with default parameters" do
          let (:params) {{ }}

          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to contain_file('/etc/audit/rules.d').with({
              :ensure  => 'directory',
              :owner   => 'root',
              :group   => 'root',
              :mode    => '0600',
              :recurse => true,
              :purge   => true
            })
          }
          it {
            is_expected.to contain_file('/etc/audit/audit.rules').with({
              :owner => 'root',
              :group => 'root',
              :mode  => 'o-rwx'
            })
          }
          it {
            is_expected.to contain_file('/etc/audit').with({
              :ensure  => 'directory',
              :owner   => 'root',
              :group   => 'root',
              :mode    => '0600',
              :recurse => true,
              :purge   => true
            })
          }
          it {
            if facts[:os][:release][:major] == '6'
             is_expected.to contain_augeas('auditd/USE_AUGENRULES').with_changes(
              ['set /files/etc/sysconfig/auditd/USE_AUGENRULES yes'])
            else
              is_expected.to_not contain_augeas('auditd/USE_AUGENRULES')
            end
          }
          it { is_expected.to_not contain_class('auditd::config::logging').that_notifies('Class[auditd::service]') }
          it {
            is_expected.to contain_file('/var/log/audit').with({
              :ensure => 'directory',
              :owner  => 'root',
              :group  => 'root',
              :mode   => 'o-rwx'
            })
          }
          it {
            is_expected.to contain_file('/var/log/audit/audit.log').with({
              :owner  => 'root',
              :group  => 'root',
              :mode   => '0600'
            })
          }
          it { is_expected.to contain_class('auditd::config::audit_profiles') }
          it { is_expected.to contain_class('auditd::config::audit_profiles::simp') }
          it { is_expected.to_not contain_class('auditd::config::audisp') }
          it { is_expected.to_not contain_class('auditd::config::audisp::syslog') }
        end   # Default params

        context 'with empty default_audit_profiles' do
          let(:params) {{ :default_audit_profiles => [] }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to_not contain_class('auditd::config::audit_profiles') }
        end

        context 'with different log_group' do
          let(:params) {{ log_group: 'rspec' }}

          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to contain_file('/etc/audit').with({
              :ensure  => 'directory',
              :owner   => 'root',
              :group   => 'rspec',
              :mode    => '0640',
              :recurse => true,
              :purge   => true
            })
          }
          it {
            is_expected.to contain_file('/etc/audit/rules.d').with({
              :ensure  => 'directory',
              :owner   => 'root',
              :group   => 'rspec',
              :mode    => '0640',
              :recurse => true,
              :purge   => true
            })
          }
          it {
            is_expected.to contain_file('/etc/audit/audit.rules').with({
              :owner => 'root',
              :group => 'rspec',
              :mode  => 'o-rwx'
            })
          }

          it {
            is_expected.to contain_file('/etc/audit/auditd.conf').with({
              :owner => 'root',
              :group => 'rspec',
              :mode  => '0640'
            })
          }

          it {
            is_expected.to contain_file('/var/log/audit').with({
              :ensure => 'directory',
              :owner  => 'root',
              :group  => 'rspec',
              :mode   => 'o-rwx'
            })
          }

          it {
            is_expected.to contain_file('/var/log/audit/audit.log').with({
              :owner  => 'root',
              :group  => 'rspec',
              :mode   => '0640'
            })
          }
        end

        context 'with deprecated parameters' do
          context 'with default_audit_profile = true' do
            let(:params) {{ :default_audit_profile => true }}

            it { is_expected.to contain_class('auditd::config::audit_profiles') }
            it { is_expected.to contain_class('auditd::config::audit_profiles::simp') }
          end

          context 'with default_audit_profile = false' do
            let(:params) {{ :default_audit_profile => false }}

            it { is_expected.to compile.with_all_deps }
            it { is_expected.to_not contain_class('auditd::config::audit_profiles') }
            it { is_expected.to_not contain_class('auditd::config::audit_profiles::simp') }
          end
        end

        context "with default_audit_profile = 'simp'" do
          let(:params) {{ :default_audit_profile => 'simp' }}

          it { is_expected.to contain_class('auditd::config::audit_profiles') }
          it { is_expected.to contain_class('auditd::config::audit_profiles::simp') }
        end

        # I have it go through both version on each os because right now the facts are not
        # created for rhel 8 and I need the audit version 3.0 tested.  Auditd version is the
        # default for rhel 8 but version 2 is the default for el6 and el7.
        [{ :auditd_version => '3.0', :auditd_major_version => '3'}, { :auditd_version => '2.4.5', :auditd_major_version => '2'}].each do |  more_facts |
          context "with auditd version #{more_facts[:auditd_major_version]}" do

            let(:facts) {
              _facts = Marshal.load(Marshal.dump(os_facts))
              _facts[:auditd_version] = more_facts[:auditd_version]
              _facts[:auditd_major_version] = more_facts[:auditd_major_version]
              _facts
              }
            let(:expected_content){ <<-EOM.gsub(/^\s+/,'')
              # This file is managed by Puppet (module 'auditd')
              log_file = /var/log/audit/audit.log
              log_format = RAW
              log_group = root
              priority_boost = 4
              flush = INCREMENTAL
              freq = 20
              num_logs = 5
              name_format = USER
              name = #{facts[:fqdn]}
              max_log_file = 24
              max_log_file_action = ROTATE
              space_left = 75
              space_left_action = SYSLOG
              admin_space_left = 50
              admin_space_left_action = SUSPEND
              disk_full_action = SUSPEND
              disk_error_action = SUSPEND
              EOM
            }
            let(:extra_content){<<-EOM.gsub(/^\s+/,'')
              write_logs = yes
              EOM
            }
            let(:v2_content){<<-EOM.gsub(/^\s+/,'')
              disp_qos = lossy
              dispatcher = /sbin/audispd
              EOM
            }
            let(:v3_content){<<-EOM.gsub(/^\s+/,'')
              # Auditd Version 3.0 or later specific options
              local_events = yes
              verify_email = yes
              q_depth = 160
              max_restarts = 10
              plugin_dir = /etc/audit/plugins.d
              EOM
            }
            let(:end_content){<<-EOM.gsub(/^\s+/,'')
              # This entry must be after verify_email if verify_email is to work
              # Note: verify_email is only an auditd version 3 option
              action_mail_acct = root
              EOM
            }

            context "with default parameters" do
              let(:params) {{ }}

              it {
                if (facts[:auditd_major_version] == '2' )
                  if ( facts[:auditd_version] < '2.5.2' )
                    # If version 2.5.2 does not have option write_logs
                    complete_content = expected_content + v2_content + end_content
                  else
                    complete_content = expected_content + extra_content + v2_content + end_content
                  end
                else
                  complete_content = expected_content + extra_content + v3_content + end_content
                end
                is_expected.to contain_file('/etc/audit/auditd.conf').with({
                  :owner   => 'root',
                  :group   => 'root',
                  :mode    => '0600',
                  :content => complete_content + "\n"
                })

                if (facts[:auditd_major_version] == '3' )
                  is_expected.to contain_file('/etc/audit/auditd.conf').with_content(%r(^local_events = .*$))
                else
                  is_expected.to contain_file('/etc/audit/auditd.conf').with_content(%r(^disp_qos = .*$))
                end
              }

            end

            context 'with syslog enabled' do
              let(:params) {{ :syslog => true }}

              it { is_expected.to contain_class('auditd::config::logging').that_notifies('Class[auditd::service]') }
              # Test private class config::logging
              it {
                if facts[:auditd_major_version] >= '3'
                  is_expected.to_not contain_class('auditd::config::audisp')
                else
                  is_expected.to contain_class('auditd::config::audisp')
                end
              }
              it { is_expected.to contain_class('auditd::config::audisp::syslog') }
            end

          end  # End auditd version context
        end  # End auditd version loop

      end # End OS Context
    end # End OS loop
  end
end
