require 'spec_helper'

describe 'wireguard' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "wireguard class without any parameters" do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('wireguard::params') }
          it { is_expected.to contain_class('wireguard::install') }
          it { is_expected.to contain_class('wireguard::config').that_requires('Class[wireguard::install]') }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'wireguard class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          :osfamily        => 'Solaris',
          :operatingsystem => 'Nexenta',
        }
      end
      it do
        expect { should compile.with_all_deps }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end
  end
end
