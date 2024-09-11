
require 'spec_helper'

describe 'borgbackup' do
  let :default_params do
    { :configdir            => '/etc/borgbackup',
      :ensure_ssh_directory => true,
      :ssh_key_define       => '',
      :ssh_key_res          => {},
      :default_target       => '',
      :repos_defaults       => {},
    }
  end


  shared_examples_for 'borgbackup class' do
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_class('borgbackup::install') }

    it { is_expected.to contain_file( params[:configdir] )
      .with_ensure( 'directory' )
      .with_owner( 'root' )
      .with_group( 'root' )
      .with_mode( '0700' )
    }
  end

  describe 'with defaults' do
    let :params do
      default_params
    end

    it_behaves_like 'borgbackup class'

    it { is_expected.to contain_file( params[:configdir] + '/.ssh')
      .with_ensure( 'directory' )
      .with_owner( 'root' )
      .with_group( 'root' )
      .with_mode( '0700' )
    }
  end

  describe 'with create repo' do
    let :params do
      default_params.merge(
        :repos => { 'default' => { 'passphrase' => 'secret' }},
	:default_target => 'irgendwo',
      )
    end

    it_behaves_like 'borgbackup class'

    it { is_expected.to contain_borgbackup__repo( 'default' )
      .with_name('default')
      .with_passphrase('secret')
      .with_target('irgendwo')
    }
  end

  describe 'with non default configuration directory' do
    let :params do
      default_params.merge(
        :configdir => '/tmp/backupdir',
      )
    end
    it_behaves_like 'borgbackup class'

    it { is_expected.to contain_file( params[:configdir] + '/.ssh')
      .with_ensure( 'directory' )
      .with_owner( 'root' )
      .with_group( 'root' )
      .with_mode( '0700' )
    }
  end

  describe 'with create .ssh directory in default location' do
    let :params do
      default_params.merge(
       :ensure_ssh_directory => false,
      )
    end
    it_behaves_like 'borgbackup class'

    it { is_expected.to_not contain_file( params[:configdir] + '/.ssh') }
  end

  describe 'with create ssh key resource' do
    let :params do
      default_params.merge(
       :ssh_key_define => 'file',
       :ssh_key_res    => {'/etc/borgbackup/.ssh/uid' => { 'owner' => 'myowner' }},
      )
    end
    it_behaves_like 'borgbackup class'

    it { is_expected.to contain_file( '/etc/borgbackup/.ssh/uid' )
      .with_owner( 'myowner')
    }
  end

end
