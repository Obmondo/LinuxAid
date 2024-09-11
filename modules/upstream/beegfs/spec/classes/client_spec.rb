require 'spec_helper'

describe 'beegfs::client' do
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
  }
  end

  it { is_expected.to contain_class('beegfs::client') }

  shared_examples 'debian_beegfs-client' do |os, codename, headers|
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

    it { is_expected.to contain_package('beegfs-client') }
    it { is_expected.to contain_package(headers) }
    it { is_expected.to contain_package('beegfs-helperd') }
    it { is_expected.to contain_package('beegfs-client') }

    it do
      is_expected.to contain_service('beegfs-client').with(
        :ensure => 'running',
        :enable => true
      )
    end

    it do
      is_expected.to contain_service('beegfs-helperd').with(
        :ensure => 'running',
        :enable => true
      )
    end

    it do
      is_expected.to contain_concat('/etc/beegfs/beegfs-mounts.conf').with({
      'ensure'  => 'present',
      'owner'   => user,
      'group'   => group,
      'mode'    => '0644'
    })
    end

    it do
      is_expected.to contain_file('/etc/beegfs/beegfs-client.conf').with({
      'ensure'  => 'present',
      'owner'   => user,
      'group'   => group,
      'mode'    => '0644',
    })
    end
  end

  context 'on debian-like system' do
    let(:user) { 'beegfs' }
    let(:group) { 'beegfs' }

    it_behaves_like 'debian_beegfs-client', 'Debian', 'squeeze', 'linux-headers-amd64'
    it_behaves_like 'debian_beegfs-client', 'Debian', 'wheezy', 'linux-headers-amd64'
    it_behaves_like 'debian_beegfs-client', 'Ubuntu', 'precise', 'linux-headers-generic'
  end

  context 'on RedHat' do
    let(:facts) do
      {
        # still old fact is needed due to this
        # https://github.com/puppetlabs/puppetlabs-apt/blob/master/manifests/params.pp#L3
        :osfamily => 'RedHat',
        :os => {
          :family => 'RedHat',
          :name => 'RedHat',
          :architecture => 'amd64',
          :release => { :major => '6', :minor => '1', :full => '6.1' },
        },
        :puppetversion => Puppet.version,
      }
    end

    let(:params) do
      {
      :kernel_ensure => '12.036+nmu3'
    }
    end

    # kernel packages have different versions than beegfs
    it do
      is_expected.to contain_package('kernel-devel').with({
      'ensure' => '12.036+nmu3'
    })
    end
  end

  context 'with given version' do
    let(:version) { '2012.10.r8.debian7' }
    let(:params) do
      {
      :package_ensure => version
    }
    end

    it do
      is_expected.to contain_package('beegfs-client').with({
      'ensure' => version
    })
    end
    it do
      is_expected.to contain_package('linux-headers-amd64').with({
      'ensure' => 'present'
    })
    end
    it do
      is_expected.to contain_package('beegfs-helperd').with({
      'ensure' => version
    })
    end
    it do
      is_expected.to contain_package('beegfs-client').with({
      'ensure' => version
    })
    end
  end

  it do
    is_expected.to contain_file('/etc/beegfs/interfaces.client').with({
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
      :interfaces_file => '/etc/beegfs/client.itf',
      :user            => user,
      :group           => group,
    }
    end

    it do
      is_expected.to contain_file('/etc/beegfs/client.itf').with({
      'ensure'  => 'present',
      'owner'   => user,
      'group'   => group,
      'mode'    => '0644',
    }).with_content(/ib0/)
    end


    it do
      is_expected.to contain_file(
        '/etc/beegfs/beegfs-client.conf'
      ).with_content(/connInterfacesFile(\s+)=(\s+)\/etc\/beegfs\/client.itf/)
    end
  end

  it do
    is_expected.to contain_file(
      '/etc/beegfs/beegfs-client.conf'
    ).with_content(/logLevel(\s+)=(\s+)3/)
  end

  context 'changing log level' do
    let(:params) do
      {
      :log_level => 5,
    }
    end

    it do
      is_expected.to contain_file(
        '/etc/beegfs/beegfs-client.conf'
      ).with_content(/logLevel(\s+)=(\s+)5/)
    end
  end

  context 'allow changing mgmtd_host' do
    let(:params) do
      {
      :mgmtd_host => '192.168.1.1',
    }
    end

    it do
      is_expected.to contain_file(
        '/etc/beegfs/beegfs-client.conf'
      ).with_content(/sysMgmtdHost(\s+)=(\s+)192.168.1.1/)
    end
  end

  context 'allow changing mgmtd port' do
    let(:params) do
      {
      :mgmtd_tcp_port => 1010,
      :mgmtd_udp_port => 1011,
    }
    end

    it do
      is_expected.to contain_file(
        '/etc/beegfs/beegfs-client.conf'
      ).with_content(/connMgmtdPortTCP(\s+)=(\s+)1010/)
    end

    it do
      is_expected.to contain_file(
        '/etc/beegfs/beegfs-client.conf'
      ).with_content(/connMgmtdPortUDP(\s+)=(\s+)1011/)
    end
  end

  context 'allow changing client ports' do
    let(:params) do
      {
      :client_udp_port  => 8010,
      :helperd_tcp_port => 8011,
    }
    end

    it do
      is_expected.to contain_file(
        '/etc/beegfs/beegfs-client.conf'
      ).with_content(/connClientPortUDP(\s+)=(\s+)8010/)
    end

    it do
      is_expected.to contain_file(
        '/etc/beegfs/beegfs-client.conf'
      ).with_content(/connHelperdPortTCP(\s+)=(\s+)8011/)
    end
  end


  context 'disable autobuild' do
    let(:params) do
      {
      :autobuild      => false,
      :autobuild_args => '-j16',
    }
    end

    it do
      is_expected.to contain_file(
        '/etc/beegfs/beegfs-client-autobuild.conf'
      ).with_content(/buildEnabled=false/)
    end

    it do
      is_expected.to contain_file(
        '/etc/beegfs/beegfs-client-autobuild.conf'
      ).with_content(/buildArgs=-j16/)
    end
  end
end
