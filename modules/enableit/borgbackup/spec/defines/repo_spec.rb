require 'spec_helper'

describe 'borgbackup::repo' do
  let :default_params do
      { :reponame       => 'title',
        :target         => '',
        :passphrase     => '',
        :passcommand    => 'default',
        :env_vars       => {},
        :archives       => {},
        :encryption     => 'keyfile',
        :append_only    => false,
        :storage_quota  => '',
        :icinga_old     => 90000,
        :crontab_define => 'cron',
        :crontabs       => {},
      }
  end

  shared_examples 'borgbackup::repo shared examples' do

    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_class('borgbackup') }

    it { is_expected.to contain_concat( '/etc/borgbackup/repo_' + params[:reponame] + '.sh' )
      .with_owner('root')
      .with_group('root')
      .with_mode('0700')
    }

    it { is_expected.to contain_concat__fragment( 'borgbackup::repo ' + params[:reponame] + ' header' )
      .with_target( '/etc/borgbackup/repo_' + params[:reponame] + '.sh' )
      .with_order( '00-header')
    }

    it { is_expected.to contain_concat__fragment( 'borgbackup::repo ' + params[:reponame] + ' footer' )
      .with_target( '/etc/borgbackup/repo_' + params[:reponame] + '.sh' )
      .with_order( '99-footer')
    }

    it { is_expected.to contain_exec('initialize borg repo ' + params[:reponame])
      .with_command( '/etc/borgbackup/repo_' + params[:reponame] + '.sh init')
      .with_unless(  '/etc/borgbackup/repo_' + params[:reponame] + '.sh list')
    }
  end

  context 'with defaults' do
    let (:title) { 'mytitle' }
    let :params do
      default_params.merge(
        :reponame => title,
      )
    end

    it_behaves_like 'borgbackup::repo shared examples'

    it { is_expected.to contain_cron('borgbackup run mytitle')
      .with_user('root')
      .with_command("/etc/borgbackup/repo_mytitle.sh run")
    }
  end

  context 'with archives' do
    let (:title) { 'mytitle' }
    let :params do
      default_params.merge(
        :reponame => title,
        :archives => { 'arch' => {} },
      )
    end

    it_behaves_like 'borgbackup::repo shared examples'

    it { is_expected.to contain_borgbackup__archive('arch')
      .with_reponame('mytitle')
    }
  end

  context 'with no cronjob' do
    let (:title) { 'no_cron' }
    let :params do
      default_params.merge(
        :reponame       => title,
        :crontab_define => '',
      )
    end

    it_behaves_like 'borgbackup::repo shared examples'
    it { is_expected.to_not contain_cron('borgbackup run no_cron') }
  end

  context 'with custom cronjob' do
    let (:title) { 'my_cron' }
    let :params do
      default_params.merge(
        :reponame => title,
        :crontabs => { 'mycustomcron' => {
                         'command' => '/bin/true',
                         'user'    => 'someuser',
                         'hour'    => 12,
                         'minute'  => 42,
                       }},
      )
    end

    it_behaves_like 'borgbackup::repo shared examples'
    it { is_expected.to_not contain_cron('borgbackup run my_cron') }
    it { is_expected.to contain_cron('mycustomcron')
      .with_command('/bin/true')
      .with_user('someuser')
      .with_hour(12)
      .with_minute(42)
    }
  end
end
