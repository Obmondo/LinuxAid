

require 'spec_helper'

describe 'borgbackup::git' do
  let(:facts) do { :fqdn  => 'myhost.somewhere.ch', }
  end

  let :default_params do
      { :packages       => ['git','gnupg'],
        :gpg_keys       => {},
	:gitrepo        => '',
	:gitrepo_sshkey => '',
	:gpg_home       => "/etc/borgbackup/.gnupg",
	:git_home       => "/etc/borgbackup/git",
      }
  end

  shared_examples 'borgbackup::git shared examples' do

    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_file( params[:gpg_home] )
	.with_ensure( 'directory' )
        .with_owner( 'root' )
        .with_group( 'root' )
        .with_mode( '0700' )
    }

    it { is_expected.to contain_exec( 'create gpg private key for myhost.somewhere.ch'  )
      .with_command("gpg --quick-generate-key --batch --passphrase '' 'borg myhost.somewhere.ch'")
    }

    it { is_expected.to contain_exec( 'setup git repo' )
      .with_creates( params[:git_home])
    }

    it { is_expected.to contain_exec( 'commit git repo' )
      .with_cwd( params[:git_home])
    }
    it { is_expected.to contain_package( 'gnupg' ) }
    it { is_expected.to contain_package( 'git' ) }

    it { is_expected.to contain_file( params[:git_home] + '/' + facts[:fqdn])
      .with_ensure(  'directory' )
      .with_owner( 'root' )
      .with_group( 'root' )
      .with_mode( '0755' )
      .with_require( 'Exec[setup git repo]' )
    }

  end

  context 'with defaults' do
    let :params do
      default_params
    end 

    it_behaves_like 'borgbackup::git shared examples'
    it { is_expected.to contain_exec( 'setup git repo' )
      .with_command(/^git init /)
    }


  end
  context 'with remote git repo' do
    let :params do
      default_params.merge(
	:gitrepo        => 'somewhere/gitrepo',
      )
    end 

    it_behaves_like 'borgbackup::git shared examples'

    it { is_expected.to contain_exec( 'setup git repo' )
      .with_command(/^git clone /)
    }

    it { is_expected.to contain_file( '/etc/borgbackup/.ssh/gitrepo_key' )
        .with_owner( 'root' )
        .with_group( 'root' )
        .with_mode( '0700' )
    }

    it { is_expected.to contain_exec( 'pull git repo' )
      .with_cwd( params[:git_home])
    }
    it { is_expected.to contain_exec( 'push git repo' )
      .with_cwd( params[:git_home])
    }
  end

end
