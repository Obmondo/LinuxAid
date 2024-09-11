require 'spec_helper'

describe 'realmd' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "realmd class without any parameters" do
          let(:params) {{ }}

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('realmd') }
          it { is_expected.to contain_class('realmd::install').that_comes_before('Class[realmd::config]') }
          it { is_expected.to contain_class('realmd::config') }
          it { is_expected.to contain_class('realmd::join').that_subscribes_to('Class[realmd::config]') }
          it { is_expected.to contain_class('realmd::sssd::config').that_requires('Class[realmd::join]') }
          it { is_expected.to contain_class('realmd::sssd::service').that_subscribes_to('Class[realmd::sssd::config]') }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'sssd class without any parameters on Solaris/Nexenta' do
      let(:facts) {{:osfamily => 'Solaris', :operatingsystem => 'Nexenta',}}
      it { expect { should contain_package('sssd') }.to raise_error(Puppet::Error) }
    end
  end
end
