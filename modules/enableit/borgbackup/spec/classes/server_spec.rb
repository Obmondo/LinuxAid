

require 'spec_helper'

describe 'borgbackup::server' do
  let :default_params do
      { :backuproot               => '/srv/borgbackup',
	:borguser                 => 'borgbackup',
	:borggroup                => 'borgbackup',
	:borghome                 => '/var/lib/borg',
	:user_ensure              => true,
	:authorized_keys_target   => '/var/lib/borgbackup/authorized-keys',
	:authorized_keys_define   => 'borgbackup::authorized_key',
	:authorized_keys          => {},
	:authorized_keys_defaults => {},
      }
  end

  shared_examples 'borgbackup::server shared examples' do

    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_file( params[:backuproot] )
	.with_ensure( 'directory' )
        .with_owner( params[:borguser] )
        .with_group( params[:borggroup] )
        .with_mode( '0700' )
    }
  end

  context 'with defaults' do
    let :params do
      default_params
    end 

    it_behaves_like 'borgbackup::server shared examples'
    it { is_expected.to contain_user( params[:borguser] )
      .with_ensure( 'present' )
      .with_comment( 'borgbackup user')
      .with_managehome( true )
      .with_home( params[:borghome] )
      .with_system( true )
    }
  end

  context 'with non default backuproot' do
    let :params do
      default_params.merge( 
	:backuproot     => '/tmp/backupdir',
      )
    end
    it_behaves_like 'borgbackup::server shared examples'
  end

  context 'with not creating user' do
    let :params do
      default_params.merge( 
	:user_ensure  => false,
      )
    end
    it_behaves_like 'borgbackup::server shared examples'

    it { is_expected.to_not contain_user( params[:borguser] ) }
  end

  describe 'with authorized-keys' do
    let :params do
      default_params.merge(
	:authorized_keys          => {'firstkey' => { 'keys' => [ 'key' ] }},
      )
    end
    it_behaves_like 'borgbackup::server shared examples'
    it { is_expected.to contain_borgbackup__authorized_key( 'firstkey')
      .with_target( params[:authorized_keys_target])
      .with_backuproot( params[:backuproot])
      .with_keys( '["key"]' )
    }
    it { is_expected.to contain_concat( params[:authorized_keys_target] )
      .with_owner( params[:borguser] )
      .with_group( params[:borggroup] )
      .with_mode( '0644' )
    }
  end

  describe 'with another authorized-keys' do
    let :params do
      default_params.merge(
       :authorized_keys_define   => 'file',
       :authorized_keys          => {'/etc/borgbackup/.ssh/authorized-keys' => { 'owner' => 'myowner', 'group' => 'mygroup' }},
      )
    end
    it_behaves_like 'borgbackup::server shared examples'

    it { is_expected.to contain_file( '/etc/borgbackup/.ssh/authorized-keys' )
      .with_owner( 'myowner' )
    }
  end

end
