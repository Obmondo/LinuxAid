require 'spec_helper'

describe 'riemann::tools', :type => :class do
  let(:facts) { {:osfamily => 'Debian', :lsbdistcodename => 'precise', :lsbmajdistrelease => 12.04} }

  it { should compile.with_all_deps }

  it { should contain_package('riemann-tools').with_provider('gem')}
  it { should contain_package('riemann-client').with_provider('gem')}
  it { should contain_package('libxml2-dev')}
  it { should contain_package('libxslt1-dev')}
  it { should contain_class('gcc')}

  context 'with services disabled' do
    let(:params) { {'health_enabled' => false, 'net_enabled' => false} }
    it { should contain_service('riemann-net').with_provider('upstart').with_enable(false)}
    it { should contain_service('riemann-health').with_provider('upstart').with_enable(false)}
    it { should_not contain_user('riemann-net')}
    it { should_not contain_user('riemann-health')}
  end

  context 'with services enabled' do
    it { should contain_service('riemann-net').with_provider('upstart').with_enable(true)}
    it { should contain_service('riemann-health').with_provider('upstart').with_enable(true)}
    it { should contain_user('riemann-net')}
    it { should contain_user('riemann-health')}
    it { should contain_file('/etc/init/riemann-health.conf').with_content(/setuid riemann-health/)}
    it { should contain_file('/etc/init/riemann-net.conf').with_content(/setuid riemann-net/)}
  end

  context 'with custom users' do
    let(:params) { { 'health_user' => 'bob', 'net_user' => 'jim'} }
    it { should contain_user('bob')}
    it { should contain_user('jim')}
    it { should contain_file('/etc/init/riemann-health.conf').with_content(/setuid bob/)}
    it { should contain_file('/etc/init/riemann-net.conf').with_content(/setuid jim/)}
  end

  context 'passing invalid params' do
    let(:params) { { 'health_enabled' => 'invalid'} }
    it do
      expect {
        should contain_package('riemann-tools')
      }.to raise_error(Puppet::Error)
    end
  end

  context 'with an invalid operating system' do
    let(:facts) { {:osfamily => 'invalid'} }
    it do
      expect {
        should contain_package('riemann-tools')
      }.to raise_error(Puppet::Error)
    end
  end

  context 'when running on RedHat/Centos' do
    let(:facts) { {:osfamily => 'RedHat', :operatingsystem => 'Centos'} }
    it { should contain_class('epel') }
    it { should contain_file('/etc/init.d/riemann-net').with_mode('0755').with_content(/\/usr\/bin\/riemann-net/)}
    it { should contain_file('/etc/init.d/riemann-health').with_mode('0755').with_content(/\/usr\/bin\/riemann-health/)}
    it { should_not contain_file('/etc/init/riemann-net.conf')}
    it { should_not contain_file('/etc/init/riemann-health.conf')}
    it { should contain_service('riemann-net').with_provider('redhat')}
    it { should contain_service('riemann-health').with_provider('redhat')}
    it { should contain_package('libxml2-devel')}
    it { should contain_package('libxslt-devel')}
  end

  context 'when running on Centos 5.8 with different gem bin path' do
    let(:facts) { {:osfamily => 'RedHat', :operatingsystem => 'Centos', :operatingsystemrelease => '5.8'} }
    it { should contain_file('/etc/init.d/riemann-net').with_mode('0755').with_content(/\/usr\/local\/bin\/riemann-net/)}
    it { should contain_file('/etc/init.d/riemann-health').with_mode('0755').with_content(/\/usr\/local\/bin\/riemann-health/)}
  end
end
