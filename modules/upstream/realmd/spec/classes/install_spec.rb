require 'spec_helper'

describe 'realmd' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "realmd::install class with default parameters" do
          let(:params) {{ }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('realmd::install') }

          case facts[:osfamily]
          when 'Debian'
            packages = [
              'realmd',
              'sssd',
              'adcli',
              'krb5-user',
              'sssd-tools',
              'libpam-modules',
              'libnss-sss',
              'libpam-sss',
              'samba-common-bin',
            ]

            packages.each do |package|
              it { is_expected.to contain_package(package).with_ensure('present') }
            end
          when 'RedHat'
            packages = [
              'realmd',
              'sssd',
              'adcli',
              'krb5-workstation',
              'oddjob',
              'oddjob-mkhomedir',
              'samba-common-tools',
            ]

            packages.each do |package|
              it { is_expected.to contain_package(package).with_ensure('present') }
            end
          end
        end
      end
    end
  end
end
