require 'spec_helper'

describe 'beegfs::mount' do
  let(:facts) do
    {
    :operatingsystem => 'Debian',
    :osfamily => 'Debian',
    :lsbdistcodename => 'wheezy',
    :lsbdistid => 'Debian',
  }
  end

  let(:title) { '/mnt/share' }

  let(:params) do
    {
    :cfg   => '/etc/beegfs/beegfs-clients.conf',
    :mnt   => '/mnt/share',
    :user  => 'root',
    :group => 'root',
  }
  end

  it do 
    should contain_concat__fragment(
      '/mnt/share'
    ).with_content('/mnt/share /etc/beegfs/beegfs-clients.conf')
  end
end
