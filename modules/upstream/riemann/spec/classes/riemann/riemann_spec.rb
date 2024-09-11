require 'spec_helper'

describe 'riemann', :type => :class do
  let(:facts) { {:osfamily => 'Debian', :lsbdistcodename => 'precise', :lsbmajdistrelease => 12.04} }

  it { should contain_class('riemann::install') }
  it { should contain_class('riemann::config') }
  it { should contain_class('riemann::service') }
  it { should contain_class('wget')}
  it { should contain_class('java')}
  it { should_not contain_class('epel') }
  it { should contain_file('/etc/riemann.sample.config') }
  it { should contain_file('/etc/puppet/riemann.yaml') }
  it { should contain_service('riemann').with_provider('upstart')}
  it { should contain_wget__fetch('download_riemann')}
  it { should contain_exec('untar_riemann')}
  it { should contain_user('riemann')}

  it { should contain_file('/etc/init/riemann.conf').with_content(/setuid riemann/) }
  it { should contain_file('/var/log/riemann.log').with_owner('riemann') }

  context 'passing a custom user' do
    let(:params) { {'user' => 'bob'} }
    it { should contain_user('bob')}
    it { should_not contain_user('riemann')}
    it { should contain_file('/etc/init/riemann.conf').with_content(/setuid bob/) }
    it { should contain_file('/var/log/riemann.log').with_owner('bob') }
  end

  context 'passing a version number' do
    let(:params) { {'version' => '1.0.0'} }
    it { should contain_exec('untar_riemann').with_creates("/opt/riemann-1.0.0/bin/riemann")}
    it { should contain_file('/opt/riemann-1.0.0').with_owner('riemann')}
  end

  context 'passing a config file' do
    let(:params) { {'config_file' => '/etc/bob/riemann.config'} }
    it { should contain_file('/etc/init/riemann.conf').with_content(/bob/)}
  end

  context 'without overriding the default host and port' do
    it { should contain_file('/etc/puppet/riemann.yaml').with_content(/localhost/)}
    it { should contain_file('/etc/puppet/riemann.yaml').with_content(/5555/)}
  end

  context 'overriding the default host and port' do
    let(:params) { {'host' => '0.0.0.0', 'port' => '6000'} }
    it { should contain_file('/etc/puppet/riemann.yaml').with_content(/0\.0\.0\.0/)}
    it { should contain_file('/etc/puppet/riemann.yaml').with_content(/6000/)}
  end

  context 'with an invalid config file path' do
    let(:params) { {'config_file' => 'not a path'} }
    it do
      expect {
        should contain_wget__fetch('download_riemann')
      }.to raise_error(Puppet::Error)
    end
  end

  context 'with an invalid operating system' do
    let(:facts) { {:osfamily => 'invalid'} }
    it do
      expect {
        should contain_wget__fetch('download_riemann')
      }.to raise_error(Puppet::Error)
    end
  end

  context 'when running on RedHat/Centos' do
    let(:facts) { {:osfamily => 'RedHat', :operatingsystem => 'Centos'} }
    it { should contain_class('epel') }
    it { should contain_package('daemonize')}
    it { should contain_file('/etc/init.d/riemann').with_mode('0755')}
    it { should_not contain_file('/etc/init/riemann.conf')}
    it { should contain_service('riemann').with_provider('redhat')}
  end

end
