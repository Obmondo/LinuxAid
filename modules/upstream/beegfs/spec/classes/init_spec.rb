require 'spec_helper'

describe 'beegfs' do
  context 'supported operating systems' do
     {
        'centos-6' => {
          :osfamily => 'RedHat',
          :os => {
            :family => 'RedHat',
            :name => 'Centos',
            :architecture => 'amd64',
            :release => { :major => '6', :minor => '2', :full => '6.2' },
          },
        },
        'ubuntu-14.04' => {
          :osfamily => 'Debian',
          :os => {
            :family => 'Debian',
            :name => 'Ubuntu',
            :architecture => 'amd64',
            :distro => { :codename => 'trusty' },
            :release => { :major => '14', :minor => '04', :full => '14.04' },
          },
        },
      }.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "beegfs class without any parameters" do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('beegfs::params') }
          #it { is_expected.to contain_class('beegfs::install').that_comes_before('beegfs::config') }
#          #it { is_expected.to contain_class('beegfs::config') }
#          #it { is_expected.to contain_class('beegfs::service').that_subscribes_to('beegfs::config') }
#
          #it { is_expected.to contain_service('beegfs') }
          #it { is_expected.to contain_package('beegfs').with_ensure('present') }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'beegfs class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          :os => {
            :family        => 'Solaris',
            :name => 'Nexenta',
          }
        }
      end

      it { expect { is_expected.to contain_package('beegfs') }.to raise_error(Puppet::Error, /Nexenta is not supported/) }
    end
  end
end
