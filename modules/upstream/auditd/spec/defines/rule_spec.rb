require 'spec_helper'

describe 'auditd::rule' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:title) { 'test' }
        let(:params) {{ :content => 'rspec_audit_message' }}
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

        it { is_expected.to compile.with_all_deps }

        context "without any parameters" do
          it {
            is_expected.to contain_class('auditd')
            is_expected.to contain_file("/etc/audit/rules.d/75.#{title}.rules").with_content(%r(#{params[:content]}))
          }
        end

        context 'when :content is an Array' do
          let(:params) {{
            :content => [
              '-a exit,always -F dir=${confdir} -F uid!=puppet -p wa -k Puppet_Config',
              '-a exit,always -F dir=${logdir} -F uid!=puppet -p wa -k Puppet_Log',
              '-a exit,always -F dir=${rundir} -F uid!=puppet -p wa -k Puppet_Run',
              '-a exit,always -F dir=${ssldir} -F uid!=puppet -p wa -k Puppet_SSL'
            ]
          }}

          it {
           is_expected.to compile.with_all_deps
           is_expected.to create_file("/etc/audit/rules.d/75.#{title}.rules").with_content(%r(^-a exit,always -F dir=))
           is_expected.to create_file("/etc/audit/rules.d/75.#{title}.rules").without_content(%r(^[^-]))
          }
        end

        context 'with :content containing extra whitespace' do
          # :content string mocks a common pattern of declaring readable auditd rules.
          let(:params) {{
            :content => '
              -a exit,always -F dir=${confdir} -F uid!=puppet -p wa -k Puppet_Config
              -a exit,always -F dir=${logdir} -F uid!=puppet -p wa -k Puppet_Log
              -a exit,always -F dir=${rundir} -F uid!=puppet -p wa -k Puppet_Run
              -a exit,always -F dir=${ssldir} -F uid!=puppet -p wa -k Puppet_SSL
            '
          }}

          it {
           is_expected.to compile.with_all_deps
           is_expected.to create_file("/etc/audit/rules.d/75.#{title}.rules").with_content(%r(^-a exit,always -F dir=))
           is_expected.to create_file("/etc/audit/rules.d/75.#{title}.rules").without_content(%r(^[^-]))
          }
        end

        context 'with :order specified' do
          let(:params) {{
            :order   => '10',
            :content => '-a exit,always -F dir=${confdir} -F uid!=puppet -p wa -k Puppet_Config'
          }}

          it {
           is_expected.to compile.with_all_deps
           is_expected.to create_file("/etc/audit/rules.d/#{params[:order]}.#{title}.rules").with_content(%r(#{Regexp.escape(params[:content])}))
          }
        end

        context 'when set to :first' do
          let(:params) {{
            :first => true,
            :content => 'audit stuff'
          }}

          it {
            is_expected.to compile.with_all_deps
            is_expected.to contain_file("/etc/audit/rules.d/10.#{title}.rules").with_content(%r(#{params[:content]}))
          }
        end

        context 'when set to :absolute :first' do
          let(:params) {{
            :first => true,
            :absolute => true,
            :content => 'audit stuff'
          }}

          it {
            is_expected.to compile.with_all_deps
            is_expected.to contain_file("/etc/audit/rules.d/01.#{title}.rules").with_content(%r(#{params[:content]}))
          }
        end

        context 'when set to :prepend' do
          let(:params) {{
            :prepend => true,
            :content => 'audit stuff'
          }}

          it {
            is_expected.to compile.with_all_deps
            is_expected.to contain_file("/etc/audit/rules.d/00.#{title}.rules").with_content(%r(#{params[:content]}))
          }
        end
      end
    end
  end
end
