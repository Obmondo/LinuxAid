require 'spec_helper'

describe 'gerrit', :type => :class do

  # Force our osfamily & operatingsystem so that puppetlabs-java
  # doesn't croak on us
  let(:facts) { {
      :fqdn             => 'my.test.com',
      :ipaddress        => '10.0.0.1',
      :osfamily         => 'RedHat',
      :operatingsystem  => 'Centos'
    } }

  context 'with defaults' do
    it { is_expected.to contain_class('gerrit') }
    it { is_expected.to contain_class('gerrit::params') }
    it { is_expected.to contain_anchor('gerrit::begin') }
    it { is_expected.to contain_class('gerrit::install') }
    it { is_expected.to contain_class('gerrit::config') }
    it { is_expected.to contain_class('gerrit::initialize') }
    it { is_expected.to contain_class('gerrit::service') }
    it { is_expected.to contain_anchor('gerrit::end') }
  end

  #####
  # gerrit::install testing
  #####

  # this would be in a separate install_spec.rb but cross sub-module
  # variable evaluation doesn't seem to work correctly then
  context 'gerrit::install' do
    it { is_expected.to contain_class('java') }
    it { is_expected.to contain_class('git') }
    it { is_expected.to contain_package('gitweb') }
    it { is_expected.to contain_user('gerrit') }

    # only need to fully validate one file for properties since the
    # definition should be an array define for all the permissions
    # setting
    it { is_expected.to contain_file('/opt/gerrit/bin').with(
          'ensure'    => 'directory',
          'owner'     => 'gerrit',
          'group'     => 'gerrit',
          'require'   => 'User[gerrit]',
          ) }
    it { is_expected.to contain_file('/opt/gerrit/etc') }
    it { is_expected.to contain_file('/opt/gerrit/lib') }
    it { is_expected.to contain_file('/opt/gerrit/logs') }
    it { is_expected.to contain_file('/opt/gerrit/plugins') }
    it { is_expected.to contain_file('/opt/gerrit/static') }
    it { is_expected.to contain_file('/opt/gerrit/tmp') }
    it { is_expected.to contain_file('/srv/gerrit') }
    it { is_expected.to contain_exec('download gerrit 2.9.3').with(
        'cwd'     => '/opt/gerrit/bin',
        'path'    => [ '/usr/bin', '/usr/sbin' ],
        'command' => 'curl -s -O https://gerrit-releases.storage.googleapis.com/gerrit-2.9.3.war',
        'creates' => '/opt/gerrit/bin/gerrit-2.9.3.war',
        'user'    => 'gerrit',
        'group'   => 'gerrit',
        ) }

    context 'with install_java false' do
      let(:params) {{ :install_java => false }}

      it { is_expected.to_not contain_class('java') }
    end

    context 'with install_git false' do
      let(:params) {{ :install_git => false }}

      it { is_expected.to_not contain_class('git') }
    end

    context 'with install_gitweb false' do
      let(:params) {{ :install_gitweb => false }}

      it { is_expected.to_not contain_package('gitweb') }
    end

    context 'with override_options[container][user] set to foo' do
      let(:params) {{ :override_options => {
        'container' => { 'user' => 'foo' }} }}

      it { is_expected.to contain_user('foo') }

      # only need to fully validate one file for properties since the
      # definition should be an array define for all the permissions
      # setting
      it { is_expected.to contain_file('/opt/gerrit/bin').with(
            'ensure'    => 'directory',
            'owner'     => 'foo',
            'group'     => 'foo',
            'require'   => 'User[foo]',
            ) }

      it { is_expected.to contain_exec('download gerrit 2.9.3').with(
          'user'  => 'foo',
          'group' => 'foo',
          ) }
    end

    # really only need to fully validate one file path since we've made sure
    # that changing the user modifies all owner, group, require already
    context 'with gerrit_home set to /var/foo' do
      let(:params) {{ :gerrit_home => '/var/foo' }}

      it { is_expected.to contain_user('gerrit').with(
            'home' => '/var/foo',
          ) }
      it { is_expected.to contain_file('/var/foo/bin').with(
            'ensure'    => 'directory',
            'owner'     => 'gerrit',
            'group'     => 'gerrit',
            'require'   => 'User[gerrit]',
          ) }
      it { is_expected.to contain_file('/var/foo/etc') }
      it { is_expected.to contain_file('/var/foo/lib') }
      it { is_expected.to contain_file('/var/foo/logs') }
      it { is_expected.to contain_file('/var/foo/plugins') }
      it { is_expected.to contain_file('/var/foo/static') }
      it { is_expected.to contain_file('/var/foo/tmp') }
      it { is_expected.to contain_exec('download gerrit 2.9.3').with(
          'cwd' => '/var/foo/bin',
          'creates' => '/var/foo/bin/gerrit-2.9.3.war',
          ) }
    end

    # verify that changing the options[gerrit][basePath] changes
    # the git storage location
    # No need to verify the permissions / validity of it being a directory
    # as that has already been tested previously
    context 'with override_options[gerrit]basePath] set to /srv/foo' do
      let(:params) {{ :override_options => {
        'gerrit' => { 'basePath' => '/srv/foo' }} }}

      it { is_expected.to contain_file('/srv/foo') }
    end

    context 'with gerrit_version 2.10.0 and download_location http://foo' do
      let(:params) {{ :gerrit_version => '2.10.0', :download_location => 'http://foo' }}
      it { is_expected.to contain_exec('download gerrit 2.10.0').with(
          'command' => 'curl -s -O http://foo/gerrit-2.10.0.war',
          'creates' => '/opt/gerrit/bin/gerrit-2.10.0.war',
          ) }
    end

  end

  #####
  # gerrit::config testing
  #####

  context 'gerrit::config' do
    it { is_expected.to contain_file('/opt/gerrit/etc/GerritSite.css').with(
        'owner'   => 'gerrit',
        'group'   => 'gerrit',
        'source'  => 'puppet:///modules/gerrit/skin/GerritSite.css',
        ) }
    it { is_expected.to contain_file('/opt/gerrit/etc/GerritSiteHeader.html').with(
        'owner'   => 'gerrit',
        'group'   => 'gerrit',
        'source'  => 'puppet:///modules/gerrit/skin/GerritSiteHeader.html',
        ) }
    it { is_expected.to contain_file('/opt/gerrit/etc/GerritSiteFooter.html',
        'owner'   => 'gerrit',
        'group'   => 'gerrit',
        'source'  => 'puppet:///modules/gerrit/skin/GerritSiteFooter.html',
        ) }
    it { is_expected.to contain_file('/opt/gerrit/etc/gerrit.config').with(
        'ensure'  => 'file',
        'owner'   => 'gerrit',
        'group'   => 'gerrit',
        'mode'    => '0660',
        ) }
    it { is_expected.to contain_file('/opt/gerrit/etc/secure.config').with(
        'ensure'  => 'file',
        'owner'   => 'gerrit',
        'group'   => 'gerrit',
        'mode'    => '0600',
        'content' => "; MANAGED BY PUPPET\n\n[auth]\n\tregisterEmailPrivateKey = mScmLr+OfBFQVPwEWxwrqlF9lXa3j7ExDU\n\trestTokenPrivateKey = datdNYTYs7Msc097wHsCu2RhqGtm1TGj9l\n\n",
        ) }
    it { is_expected.to contain_gerrit__config__git_config('gerrit.config').with(
        'config_file' => '/opt/gerrit/etc/gerrit.config',
        'mode'        => '0660',
        ) }
    it { is_expected.to contain_file('gerrit_init_script').with(
        'ensure'  => 'link',
        'path'    => '/etc/init.d/gerrit',
        'target'  => '/opt/gerrit/bin/gerrit.sh',
        ) }
    it { is_expected.to contain_file('gerrit_defaults').with(
        'ensure'  => 'file',
        'owner'   => 'gerrit',
        'group'   => 'gerrit',
        'mode'    => '0644',
        'content' => "GERRIT_SITE=/opt/gerrit\n",
        ) }
    it { is_expected.to contain_firewall('050 gerrit webui access').with(
        'proto'   => 'tcp',
        'state'   => ['NEW'],
        'action'  => 'accept',
        'port'    => ['8080'],
        ) }
    it { is_expected.to contain_firewall('050 gerrit ssh access').with(
        'proto'   => 'tcp',
        'state'   => ['NEW'],
        'action'  => 'accept',
        'port'    => ['29418'],
        ) }

    context 'with manage_site_skin false' do
      let(:params) {{ :manage_site_skin => false }}

      it { is_expected.to_not contain_file('/opt/gerrit/etc/GerritSite.css') }
      it { is_expected.to_not contain_file('/opt/gerrit/etc/GerritSiteHeader.html') }
      it { is_expected.to_not contain_file('/opt/gerrit/etc/GerritSiteFooter.html') }
    end

    context 'with override_secure_options set' do
      let(:params) {{
        :override_secure_options => {
          'auth' => {
            'registerEmailPrivateKey' => 'foo',
            'restTokenPrivateKey' => 'bar'
          }
        }
      }}

      it { is_expected.to contain_file('/opt/gerrit/etc/secure.config').with(
          'content' => "; MANAGED BY PUPPET\n\n[auth]\n\tregisterEmailPrivateKey = foo\n\trestTokenPrivateKey = bar\n\n",
          ) }
    end

    context 'with custom site skin, home dir, user' do
      let(:params) {{
          :gerrit_home => '/var/foo',
          :override_options => {
            'container' => { 'user' => 'foo' }
          },
          :gerrit_site_options => {
            'GerritSite.css'        => 'puppet:///private/GerritSite.css',
            'GerritSiteHeader.html' => 'puppet:///private/GerritSiteHeader.html',
            'GerritSiteFooter.html' => 'puppet:///private/GerritSiteFooter.html',
          }
        }}

      it { is_expected.to contain_file('/var/foo/etc/GerritSite.css').with(
          'owner'   => 'foo',
          'group'   => 'foo',
          'source'  => 'puppet:///private/GerritSite.css',
          ) }
      it { is_expected.to contain_file('/var/foo/etc/GerritSiteHeader.html').with(
          'owner'   => 'foo',
          'group'   => 'foo',
          'source'  => 'puppet:///private/GerritSiteHeader.html',
          ) }
      it { is_expected.to contain_file('/var/foo/etc/GerritSiteFooter.html').with(
          'owner'   => 'foo',
          'group'   => 'foo',
          'source'  => 'puppet:///private/GerritSiteFooter.html',
          ) }
    end

    context 'using mysql' do
      let(:params) {{
        :db_tag => 'test',
        :override_options => {
          'database' => {
            'type'      => 'MYSQL',
            'hostname'  => 'db.test.com',
            'database'  => 'gerrit',
            'username'  => 'gerrit',
          }
        },
        :override_secure_options => {
          'database' => {
            'password' => 'somepassword',
          },
        },
      }}

      it { is_expected.to contain_class('gerrit::config::db::mysql') }

      # We can't test for exported resources :(
      #it { is_expected.to contain_class('mysql::db') }
    end

    context 'using posgresql' do
      let(:params) {{
        :db_tag => 'test',
        :override_options => {
          'database' => {
            'type'      => 'POSTGRESQL',
            'hostname'  => 'db.test.com',
            'database'  => 'gerrit',
            'username'  => 'gerrit',
          }
        },
        :override_secure_options => {
          'database' => {
            'password' => 'somepassword',
          },
        },
      }}

      it { is_expected.to contain_class('gerrit::config::db::postgresql') }
    end

    context 'not managing firewall' do
      let(:params) {{
        :manage_firewall => false,
      }}

      it { is_expected.to_not contain_firewall('050 gerrit webui access') }
      it { is_expected.to_not contain_firewall('050 gerrit ssh access') }
    end

    context 'firewall with alternative addresses and ports' do
      let(:params) {{
        :override_options => {
          'httpd' => {
            'listenUrl' => 'http://10.0.0.1:8082/',
          },
          'sshd'  => {
            'listenAddress' => '10.0.0.1:23000',
          },
        },
      }}

      it { is_expected.to contain_firewall('050 gerrit webui access').with(
          'proto'       => 'tcp',
          'state'       => ['NEW'],
          'action'      => 'accept',
          'destination' => '10.0.0.1',
          'port'        => ['8082'],
          ) }
      it { is_expected.to contain_firewall('050 gerrit ssh access').with(
          'proto'       => 'tcp',
          'state'       => ['NEW'],
          'action'      => 'accept',
          'destination' => '10.0.0.1',
          'port'        => ['23000'],
          ) }

    end

  end

  #####
  # gerrit::initialize testing
  #####
  context 'gerrit::initialize' do
    context 'with defaults' do
      it { is_expected.to contain_exec('gerrit_initialize').with(
        'cwd'     => '/opt/gerrit',
        'command' => 'java -jar /opt/gerrit/bin/gerrit-2.9.3.war init -d /opt/gerrit --batch && java -jar /opt/gerrit/bin/gerrit.war reindex -d /opt/gerrit',
        'creates' => '/srv/gerrit/All-Projects.git/HEAD',
        'path'    => [ '/usr/bin', '/usr/sbin' ],
        'user'    => 'gerrit',
      ) }
    end
  end

  #####
  # gerrit::service testing
  #####

  context 'gerrit::service' do
    context 'with defaults' do
      it { is_expected.to contain_service('gerrit').with(
          :ensure   => true,
          :enable   => true,
        ) }
    end

    context 'service_enabled is incorrect' do
      let(:params) {{ :service_enabled => 'invalid_val' }}
      it 'should report an error when service_enabled is incorrect' do
        expect { subject }.to raise_error(Puppet::Error,
                                          /invalid_val is not supported for service_enabled\. Allowed values are true, false, 'manual'\./)
      end
    end

    context 'service_enabled set to false' do
      let(:params) {{ :service_enabled => false }}

      it { is_expected.to contain_service('gerrit').with(
          :ensure => false
        ) }
    end
  end
end

# vim: sw=2 ts=2 sts=2 et :

