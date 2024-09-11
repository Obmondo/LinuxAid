require 'spec_helper'

describe 'wireguard::install' do
  let :default_params do
    {
      'package_name'   => [
        'wireguard-dkms',
        'wireguard-tools'
      ],
      'repo_url'       => 'http://some.repos.url',
      'manage_repo'    => false,
      'manage_package' => false,
      'package_ensure' => 'installed',
    }
  end
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "wireguard::install class without any parameters" do
          it do
            expect { should compile.with_all_deps }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
          end
        end
        context "wireguard::install class with all parameters defined" do
          let (:params) do
            default_params
          end
          it { is_expected.to compile.with_all_deps }

          case facts[:osfamily]
          when 'RedHat'
            context "wireguard::install class with manage_repo = true" do
              let (:params) do
                default_params.merge({
                                       'manage_repo' => true,
                                     })
              end
              it { is_expected.to contain_exec('download_wireguard_repo')}
            end
          when 'Debian'
            case facts[:operatingsystem]
            when 'Ubuntu'
              context "wireguard::install class with manage_repo = true" do
                let (:params) do
                  default_params.merge({
                                        'manage_repo' => true,
                                      })
                end
                it { is_expected.to contain_class('Apt')}
                it { is_expected.to contain_apt__ppa('http://some.repos.url')}
            end
            when 'Debian'
              context "wireguard::install class with manage_repo = true" do
                let (:params) do
                  default_params.merge({
                                        'manage_repo' => true,
                                      })
                end
                it { is_expected.to contain_class('Apt')}
                it { is_expected.to contain_apt__pin('debian_unstable')}
                it { is_expected.to contain_apt__source('debian_unstable')}
            end
            end
          end


          context "wireguard::install class with manage_package = true" do
            let (:params) do
              default_params.merge({
                                     'manage_package' => true,
                                   })
            end
            it { is_expected.to contain_package('wireguard-dkms').with_ensure('installed')}
            it { is_expected.to contain_package('wireguard-tools').with_ensure('installed')}
            context "install custom package whit manage_repo = false" do
              let (:params) do
                default_params.merge({
                                       'manage_package' => true,
                                       'manage_repo' => false,
                                       'package_name' => 'my-wg-pkg'
                                     })
              end
              it { is_expected.to contain_package('my-wg-pkg').with_ensure('installed').without_require}
            end
          end
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'wireguard::install class without any parameters on Solaris/Nexenta' do
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
