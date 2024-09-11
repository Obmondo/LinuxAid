require 'spec_helper'

describe 'wireguard::config' do
  let :default_params do
    {
      'config_dir'      => '/etc/wireguard',
      'config_dir_mode' => '0700'
    }
  end
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "wireguard::config class without any parameters" do
          it do
            expect { should compile.with_all_deps }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
          end
        end
        context "wireguard::config class with all parameters defined" do
          let (:params) do
            default_params
          end
          it { is_expected.to compile.with_all_deps }
          it do
            is_expected.to contain_file('/etc/wireguard').with( {'ensure' => 'directory',
                                  'mode'   => '0700',
                                  'owner'  => 'root',
                                  'group'  => 'root',})
          end
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'wireguard::config class without any parameters on Solaris/Nexenta' do
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
