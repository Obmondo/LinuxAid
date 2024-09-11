require 'spec_helper'

describe 'beegfs::meta' do
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

  it { is_expected.to contain_class('beegfs::meta') }
  it { is_expected.to contain_class('beegfs::install') }

  shared_examples 'debian-meta' do |os, codename|
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
    it { is_expected.to contain_package('beegfs-meta') }
    it { is_expected.to contain_package('beegfs-utils') }

    it { is_expected.to contain_class('beegfs::repo::debian') }

    it do
      is_expected.to contain_service('beegfs-meta').with(
        :ensure => 'running',
        :enable => true
      )
    end

    it do
      is_expected.to contain_file('/etc/beegfs/beegfs-meta.conf').with({
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

    it_behaves_like 'debian-meta', 'Debian', 'wheezy'
    it_behaves_like 'debian-meta', 'Ubuntu', 'precise'
  end

  shared_examples 'beegfs-version' do |release|

    context 'allow changing parameters' do
      let(:params) do
        {
        :mgmtd_host => '192.168.1.1',
        :release => release,
      }
      end

      it do
        is_expected.to contain_file(
          '/etc/beegfs/beegfs-meta.conf'
        ).with_content(/sysMgmtdHost(\s+)=(\s+)192.168.1.1/)
      end
    end

    context 'with given version' do
      let(:facts) do
        {
          # still old fact is needed due to this
          # https://github.com/puppetlabs/puppetlabs-apt/blob/master/manifests/params.pp#L3
          :osfamily => 'Debian',
          :os => {
            :family => 'Debian',
            :name => 'Debian',
            :architecture => 'amd64',
            :distro => { :codename => 'wheezy' },
            :release => { :major => '7', :minor => '1', :full => '7.1' },
          },
          :puppetversion => Puppet.version,
        }
      end
      let(:version) { '2015.03.r8.debian7' }
      let(:params) do
        {
        :package_ensure => version,
        :release => release,
      }
      end

      it do
        is_expected.to contain_package('beegfs-meta').with({
        'ensure' => version
      })
      end
    end

    it do
      is_expected.to contain_file('/etc/beegfs/interfaces.meta').with({
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
        :interfaces_file => '/etc/beegfs/meta.itf',
        :user            => user,
        :group           => group,
        :release   => release,
      }
      end

      it do
        is_expected.to contain_file('/etc/beegfs/meta.itf').with({
        'ensure'  => 'present',
        'owner'   => user,
        'group'   => group,
        'mode'    => '0644',
      }).with_content(/ib0/)
      end


      it do
        is_expected.to contain_file(
          '/etc/beegfs/beegfs-meta.conf'
        ).with_content(/connInterfacesFile(\s+)=(\s+)\/etc\/beegfs\/meta.itf/)
      end
    end

    it do
      is_expected.to contain_file(
        '/etc/beegfs/beegfs-meta.conf'
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
          '/etc/beegfs/beegfs-meta.conf'
        ).with_content(/logLevel(\s+)=(\s+)5/)
      end
    end

    context 'hiera should override defaults' do
      let(:params) do
        {
        :mgmtd_host => '192.168.1.1',
        :release => release,
      }
      end

      it do
        is_expected.to contain_file(
          '/etc/beegfs/beegfs-meta.conf'
        ).with_content(/sysMgmtdHost(\s+)=(\s+)192.168.1.1/)
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
          '/etc/beegfs/beegfs-meta.conf'
        ).with_content(/storeAllowFirstRunInit(\s+)=(\s+)false/)
      end
    end
  end

  context 'with beegfs' do
    it_behaves_like 'beegfs-version', '2015.03'
    it_behaves_like 'beegfs-version', '6'
  end
end
