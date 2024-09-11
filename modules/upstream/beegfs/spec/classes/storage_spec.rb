require 'spec_helper'

describe 'beegfs::storage' do
  let(:hiera_data) { { 'beegfs::mgmtd_host' => "foo.bar" } }

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
    'user'  => user,
    'group' => group,
    :release => '2015.03',
  }
  end

  it { is_expected.to contain_class('beegfs::storage') }

  shared_examples 'debian-storage' do |os, codename|
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

    it { is_expected.to contain_package('beegfs-utils') }
    it do
      is_expected.to contain_service('beegfs-storage').with(
        :ensure => 'running',
        :enable => true
      )
    end

    it do
      is_expected.to contain_file('/etc/beegfs/beegfs-storage.conf').with({
        'ensure'  => 'present',
        'owner'   => user,
        'group'   => group,
        'mode'    => '0644',
      })
    end

    it do
      is_expected.to contain_file('/srv/beefgs/storage').with({
        'ensure'  => 'directory',
        'owner'   => user,
        'group'   => group,
      })
    end

    it do
      is_expected.to contain_service('beegfs-storage').with(
        :ensure => 'running',
        :enable => true
      )
    end
  end

  context 'on debian-like system' do
    let(:user) { 'beegfs' }
    let(:group) { 'beegfs' }

    let(:params) do
      {
      'user'  => user,
      'group' => group,
      :release => '2015.03',
      :storage_directory => ['/srv/beefgs/storage'],
    }
    end

    it_behaves_like 'debian-storage', 'Debian', 'wheezy'
    it_behaves_like 'debian-storage', 'Ubuntu', 'precise'
  end

  shared_examples 'beegfs-version' do |release|

    let(:user) { 'beegfs' }
    let(:group) { 'beegfs' }

    let(:params) do
    {
      'user'  => user,
      'group' => group,
      :release => release,
      :storage_directory => ['/srv/beefgs/storage'],
    }
    end

    context 'with given version' do
      let(:version) { '2012.10.r8.debian7' }
      let(:params) do
        {
        :package_ensure => version,
        :release  => release,
      }
      end

      it do
        is_expected.to contain_package('beegfs-storage').with({
        'ensure' => version
      })
      end
    end

    it do
      is_expected.to contain_file('/etc/beegfs/interfaces.storage').with({
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
        :interfaces_file => '/etc/beegfs/store.itf',
        :user            => user,
        :group           => group,
        :release   => release,
      }
      end

      it do
        is_expected.to contain_file('/etc/beegfs/store.itf').with({
        'ensure'  => 'present',
        'owner'   => user,
        'group'   => group,
        'mode'    => '0644',
      }).with_content(/ib0/)
      end


      it do
        is_expected.to contain_file(
          '/etc/beegfs/beegfs-storage.conf'
        ).with_content(/connInterfacesFile(\s+)=(\s+)\/etc\/beegfs\/store.itf/)
      end
    end

    it do
      is_expected.to contain_file(
        '/etc/beegfs/beegfs-storage.conf'
      ).with_content(/logLevel(\s+)=(\s+)3/)
    end

    context 'changing log level' do
      let(:params) do
        {
        :log_level => 5,
        :release => release,
      }
      end

      it do
        is_expected.to contain_file(
          '/etc/beegfs/beegfs-storage.conf'
        ).with_content(/logLevel(\s+)=(\s+)5/)
      end
    end

    context 'set mgmtd host' do
      let(:params) do
        {
        :mgmtd_host => 'mgmtd.beegfs.com',
        :release => release,
      }
      end

      it do
        is_expected.to contain_file(
          '/etc/beegfs/beegfs-storage.conf'
        ).with_content(/sysMgmtdHost(\s+)=(\s+)mgmtd.beegfs.com/)
      end
    end

    context 'set mgmtd tcp port' do
      let(:params) do
        {
        :mgmtd_tcp_port => 9009,
        :release  => release,
      }
      end

      it do
        is_expected.to contain_file(
          '/etc/beegfs/beegfs-storage.conf'
        ).with_content(/connMgmtdPortTCP(\s+)=(\s+)9009/)
      end
    end

    context 'pass storage directory as an array' do
      let(:params) do
        {
        :storage_directory => ['/var/storage1','/var/storage2'],
        :release => release,
        :user => user,
        :group => group,
      }
      end

      it do
        is_expected.to contain_file(
          '/etc/beegfs/beegfs-storage.conf'
        ).with_content(/storeStorageDirectory(\s+)=(\s+)\/var\/storage1,\/var\/storage2/)
      end

      it do
        is_expected.to contain_file('/var/storage1').with({
          'ensure'  => 'directory',
          'owner'   => user,
          'group'   => group,
        })
      end

      it do
        is_expected.to contain_file('/var/storage2').with({
          'ensure'  => 'directory',
          'owner'   => user,
          'group'   => group,
        })
      end
    end

    context 'disable first run init' do
      let(:params) do
        {
        :allow_first_run_init => false,
        :release => release,
      }
      end

      it do
        is_expected.to contain_file(
          '/etc/beegfs/beegfs-storage.conf'
        ).with_content(/storeAllowFirstRunInit(\s+)=(\s+)false/)
      end
    end
  end

  context 'with beegfs' do
    it_behaves_like 'beegfs-version', '2015.03'
    it_behaves_like 'beegfs-version', '6'
  end
end
