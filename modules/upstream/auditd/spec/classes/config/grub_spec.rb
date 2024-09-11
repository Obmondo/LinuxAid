require 'spec_helper'

describe 'auditd::config::grub' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          if ['RedHat','CentOS'].include?(facts[:operatingsystem]) && facts[:operatingsystemmajrelease].to_s < '7'
            facts[:apache_version] = '2.2'
            facts[:grub_version] = '0.9'
          else
            facts[:apache_version] = '2.4'
            facts[:grub_version] = '2.0~beta'
          end
          if ! facts[:auditd_major_version]
             if facts[:os][:release][:major] < '8'
               facts[:auditd_major_version] = '2'
             else
               facts[:auditd_major_version] = '3'
             end
          end
          facts
        end

        it { is_expected.to compile.with_all_deps }

        context "without any parameters" do
          let(:params) {{ }}
          it { is_expected.to contain_kernel_parameter('audit').with_value('1') }
          it {
            is_expected.to contain_reboot_notify('audit').that_subscribes_to('Kernel_parameter[audit]')
          }
        end

        context 'when disabled' do
          let(:params) {{
            :enable => false
          }}
          it { is_expected.to contain_kernel_parameter('audit').with_value('0') }
          it {
            is_expected.to contain_reboot_notify('audit').that_subscribes_to('Kernel_parameter[audit]')
          }
        end
      end
    end
  end
end
