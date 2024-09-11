require 'spec_helper'

describe 'uwsgi' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "uwsgi class without any parameters" do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('uwsgi::params') }
          it { is_expected.to contain_class('uwsgi::install').that_comes_before('uwsgi::config') }
          it { is_expected.to contain_class('uwsgi::config') }
          it { is_expected.to contain_class('uwsgi::service').that_subscribes_to('uwsgi::config') }

          it { is_expected.to contain_service('uwsgi') }
          it { is_expected.to contain_package('uwsgi').with_ensure('present') }

          it { should contain_user('uwsgi') }
          it { should contain_file('/etc/uwsgi/emperor.ini') }
          it { should contain_file('/etc/uwsgi').with_ensure('directory') }
          it do
            should contain_file('/etc/uwsgi/vassals.d').with(
              'ensure' => 'directory',
              'recurse' => true,
              'purge' => true
            )
          end
          it { should contain_file('/etc/uwsgi/plugins').with_ensure('directory') }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'uwsgi class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          :osfamily        => 'Solaris',
          :operatingsystem => 'Nexenta',
        }
      end

      it { expect { is_expected.to contain_package('uwsgi') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end

  context "on osfamily => Redhat" do
      let (:facts) do
        {
            :osfamily => 'Redhat',

        }
      end

      it { should contain_file('/etc/init.d/uwsgi').with_ensure('present') }
      it { should contain_file('/etc/init.d/uwsgi').with_content(/RUNAS="uwsgi"/) }
      it { should_not contain_package('python-devel') }
      it { should_not contain_package('pip') }
  end

  context "on osfamily => Debain" do
      let (:facts) do
          {
            :osfamily => 'Debian'
          }
      end
      it { should contain_file('/etc/init/uwsgi.conf') }
      it { should_not contain_package('python-dev') }
      it { should_not contain_package('python-pip') }
  end
end
