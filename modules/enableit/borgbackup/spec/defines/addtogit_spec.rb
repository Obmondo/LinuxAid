

require 'spec_helper'

describe 'borgbackup::addtogit' do
  let(:pre_condition) { 'borgbackup::repo{"test": }' }

  shared_examples 'borgbackup::addtogit shared examples' do

    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_class('borgbackup::git') }

    it { is_expected.to contain_exec('create passphrase file ' + title )
      .with_environment(/GNUPGHOME=/)
    }

    it { is_expected.to contain_exec('create key file ' + title )
      .with_environment(/GNUPGHOME=/)
      .with_notify('Exec[commit git repo]')
      .with_provider('shell')
    }

    it { is_expected.to contain_exec('reencrypt key file ' + title )
      .with_environment(/GNUPGHOME=/)
      .with_notify('Exec[commit git repo]')
    }

    it { is_expected.to contain_exec('reencrypt passphrase file ' + title )
      .with_environment(/GNUPGHOME=/)
      .with_notify('Exec[commit git repo]')
    }
  end

  context 'with defaults' do
    let (:title) { 'mytitle' }
    let :params do 
      {
        :passphrase => 'random',
	:reponame   => 'test',
      }
    end
    it_behaves_like 'borgbackup::addtogit shared examples'
  end

  context 'with configured passphrase' do
    let (:title) { 'mytitle' }
    let :params do 
      {
      :passphrase => 'secret',
      :reponame   => 'test',
      }
    end
    it_behaves_like 'borgbackup::addtogit shared examples'
  end

end
