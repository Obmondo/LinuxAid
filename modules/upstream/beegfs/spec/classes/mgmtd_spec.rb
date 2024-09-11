require 'spec_helper'

describe 'beegfs::mgmtd' do
  let(:facts) do
    {
      # still old fact is needed due to this
      # https://github.com/puppetlabs/puppetlabs-apt/blob/master/manifests/params.pp#L3
      :osfamily => 'Debian',
      :os => {
        :family => 'Debian',
        :name => 'Debian',
        :architecture => 'amd64',
        :distro => { :codename => 'jessie' },
        :release => { :major => '7', :minor => '1', :full => '7.1' },
      },
      :puppetversion => Puppet.version,
    }
  end

  let(:user) { 'beegfs' }
  let(:group) { 'beegfs' }

  let(:params) do
    {
    :user  => user,
    :group => group,
    :release => '2015.03',
  }
  end

  shared_examples 'debian-mgmtd' do |os, codename|
    let(:facts) do
      {
        # still old fact is needed due to this
        # https://github.com/puppetlabs/puppetlabs-apt/blob/master/manifests/params.pp#L3
        :osfamily => 'Debian',
        :os => {
          :family => 'Debian',
          :name => os,
          :architecture => 'amd64',
          :distro => { :codename => codename },
          :release => { :major => '7', :minor => '1', :full => '7.1' },
        },
        :puppetversion => Puppet.version,
      }
    end

    let(:params) do
      {
      :user  => user,
      :group => group,
      :release => '2015.03',
    }
    end
    it { is_expected.to contain_package('beegfs-mgmtd') }
    it { is_expected.to contain_package('beegfs-utils') }

    it { is_expected.to contain_class('beegfs::repo::debian') }

    it do
      is_expected.to contain_service('beegfs-mgmtd').with(
        :ensure => 'running',
        :enable => true
      )
    end
  end

  context 'on debian-like system' do
    it_behaves_like 'debian-mgmtd', 'Debian', 'wheezy'
    it_behaves_like 'debian-mgmtd', 'Ubuntu', 'precise'
  end

  context 'with given version' do
    let(:version) { '2012.10.r8.debian7' }
    let(:params) do
      {
      :package_ensure => version,
      :user           => user,
      :group          => group,
      :release => '2015.03',
    }
    end

    it do
      should contain_package('beegfs-mgmtd').with({
      'ensure' => version
    })
    end
  end

  it do
    should contain_file('/etc/beegfs/interfaces.mgmtd').with({
    'ensure'  => 'present',
    'owner'   => user,
    'group'   => group,
    'mode'    => '0644',
  }).with_content(/eth0/)
  end

  context 'interfaces file' do
    let(:params) do
      {
      :interfaces      => ['eth0', 'ib0'],
      :interfaces_file => '/etc/beegfs/mgmtd.itf',
      :user            => user,
      :group           => group,
      :release   => '2015.03',
    }
    end

    it do
      should contain_file('/etc/beegfs/mgmtd.itf').with({
      'ensure'  => 'present',
      'owner'   => user,
      'group'   => group,
      'mode'    => '0644',
    }).with_content(/ib0/)
    end


    it do
      should contain_file(
        '/etc/beegfs/beegfs-mgmtd.conf'
      ).with_content(/connInterfacesFile(\s+)=(\s+)\/etc\/beegfs\/mgmtd.itf/)
    end
  end

  it do
    should contain_file(
      '/etc/beegfs/beegfs-mgmtd.conf'
    ).with_content(/logLevel(\s+)=(\s+)2/)
  end

  context 'changing log level' do
    let(:params) do
      {
      :log_level => 5,
      :release => '2015.03',
    }
    end

    it do
      should contain_file(
        '/etc/beegfs/beegfs-mgmtd.conf'
      ).with_content(/logLevel(\s+)=(\s+)5/)
    end
  end
end
