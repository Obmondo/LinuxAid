

require 'spec_helper'

describe 'borgbackup::authorized_key' do
  let :default_params do
      { :reponame               => 'title',
	:keys                   => [],
	:restrict_to_path       => '',
	:restrict_to_repository => 'yes',
	:append_only            => false,
	:storage_quota          => '',
	:restricts              => ['restrict'],
	:env_vars               => {},
      }
  end

  shared_examples 'borgbackup::authorized_key shared examples' do

    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_concat__fragment( title )
      .with_target( params[:target] )
      .with_order( title )
    }
  end

  context 'with defaults' do
    let (:title) { 'mytitle' }
    let :params do
      default_params.merge( 
	:reponame   => title,
        :backuproot => 'mybackuproot',
        :target     => 'mytarget',
      )
    end
    it_behaves_like 'borgbackup::authorized_key shared examples'
  end

  context 'with keys' do
    let (:title) { 'mytitle' }
    let :params do
      default_params.merge( 
	:reponame   => title,
        :backuproot => 'mybackuproot',
        :target     => 'mytarget',
	:keys       => ['rsa mykey'],
      )
    end
    it_behaves_like 'borgbackup::authorized_key shared examples'
    it { is_expected.to contain_concat__fragment( title )
      .with_content(/rsa mykey/)
    }
  end

end
