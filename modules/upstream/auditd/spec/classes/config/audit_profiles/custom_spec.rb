require 'spec_helper'

describe 'auditd::config::audit_profiles::custom' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts){ os_facts }

      let(:common_pre_condition) {
        <<-EOM
          function assert_private() { }

          class auditd::config ( $profiles = ['custom'] ){}
          include auditd::config
        EOM
      }

      let(:pre_condition) { common_pre_condition }

      context 'with rules specified' do
        let(:params) {{
          :rules => [
            'First Rule',
            'Second Rule'
          ]
        }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file('/etc/audit/rules.d/50_00_custom_base.rules').with_content(params[:rules].join("\n") + "\n") }
      end

      context 'when using templates' do
        context 'with EPP template specified' do
          let(:params) {{
            :template => 'foo/bar.epp'
          }}

          let(:pre_condition) {
            <<-EOM
              #{common_pre_condition}

              function epp($arg) >> String { 'EPP!' }
            EOM
          }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file('/etc/audit/rules.d/50_00_custom_base.rules').with_content("EPP!\n") }
        end

        context 'with ERB template specified' do
          let(:params) {{
            :template => 'foo/bar.erb'
          }}

          let(:pre_condition) {
            <<-EOM
              #{common_pre_condition}

              function template($arg) >> String { 'ERB!' }
            EOM
          }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file('/etc/audit/rules.d/50_00_custom_base.rules').with_content("ERB!\n") }
        end

        context 'with an invalid template name specified' do
          let(:params) {{
            :template => 'foo/bar.bad'
          }}

          it { expect{is_expected.to compile.with_all_deps}.to raise_error(/must end with/) }
        end
      end

      context 'with invalid options' do
        it 'should require $rules or $template' do
          expect{is_expected.to compile.with_all_deps}.to raise_error(/must specify either/)
        end

        context 'with both $rules and $template' do
          let(:params) {{
            :rules => ['RULEZ'],
            :template => 'foo/bar.epp'
          }}

          it { expect{is_expected.to compile.with_all_deps}.to raise_error(/may not specify/) }
        end
      end

      context 'with other profiles specified' do
        let(:pre_condition) {
          <<-EOM
            function assert_private() { }

            class auditd::config (
              $profiles = ['simp', 'custom', 'stig']
            ){}
            include auditd::config
          EOM
        }

        let(:params) {{
          :rules => [
            'First Rule',
            'Second Rule'
          ]
        }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file('/etc/audit/rules.d/50_01_custom_base.rules').with_content(params[:rules].join("\n") + "\n") }
      end
    end
  end
end
