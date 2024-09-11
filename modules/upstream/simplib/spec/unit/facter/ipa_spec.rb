require 'spec_helper'

describe "custom fact ipa" do
  let (:ipa_query_options) {
    {:timeout => 30}
  }

  let (:kinit_query_options) {
    {:timeout => 10}
  }

  let (:ipa_env_query) {
    '/usr/bin/ipa env domain server realm basedn tls_ca_cert'
  }

  let (:ipa_env_server_query) {
    '/usr/bin/ipa env --server host'
  }

  let (:default_conf) {
    [
      '#host = client.example.com',
      'host=client.example.com',
      'basedn = dc=example,dc=com',
      'realm = EXAMPLE.COM',
      'domain = example.com',
      'server = ipaserver.example.com',
      'xmlrpc_uri = https://ipaserver.example.com/ipa/xml',
      'ldap_uri = ldapi://%2fvar%2frun%2fslapd-EXAMPLE-COM.socket',
      'enable_ra = True',
      'ra_plugin = dogtag',
      'dogtag_version = 10',
      'mode = production'
    ].join("\n")
  }

  let (:ipa_env) {
    [
      '  domain: example.com',
      '  server: ipaserver.example.com',
      '  realm:  EXAMPLE.COM',
      '  basedn: dc=example,dc=com',
      '-----------',
      '4 variables',
      '-----------'
    ].join("\n")
  }

  let (:ipa_server_env) {
    'host: ipaserver.example.com'
  }

  before(:each) do
    Facter.clear

    # mock out Facter method called when evaluating confine for :kernel
    Facter::Core::Execution.stubs(:exec).with('uname -s').returns('Linux')
  end

  context 'host is joined to IPA domain' do
    context 'IPA server is available' do
      context 'kinit is not required' do
        it 'should execute only ipa commands and report local env + connected status' do
          Facter::Core::Execution.expects(:which).with('kinit').returns('/usr/bin/kinit')
          Facter::Core::Execution.expects(:which).with('ipa').returns('/usr/bin/ipa')
          File.expects(:exist?).with('/etc/ipa/default.conf').returns(true)
          File.expects(:read).with('/etc/ipa/default.conf').returns(default_conf)
          Facter::Core::Execution.expects(:execute).with(ipa_env_query, ipa_query_options).returns(ipa_env)
          Facter::Core::Execution.expects(:execute).with(ipa_env_server_query, ipa_query_options).returns(ipa_server_env)
          expect(Facter.fact('ipa').value).to eq({
            'connected' => true,
            'domain'    => 'example.com',
            'server'    => 'ipaserver.example.com',
            'realm'     => 'EXAMPLE.COM',
            'basedn'    => 'dc=example,dc=com'
          })
        end
      end

      context 'kinit is required' do
        it 'should execute kinit + ipa commands and return local env + connected status' do
          Facter::Core::Execution.expects(:which).with('kinit').returns('/usr/bin/kinit')
          Facter::Core::Execution.expects(:which).with('ipa').returns('/usr/bin/ipa')
          File.expects(:exist?).with('/etc/ipa/default.conf').returns(true)
          File.expects(:read).with('/etc/ipa/default.conf').returns(default_conf)
          Facter::Core::Execution.expects(:execute).with('/usr/bin/kinit -k 2>&1', kinit_query_options).returns('')
          Facter::Core::Execution.expects(:execute).twice.with( ipa_env_query, ipa_query_options).returns('', ipa_env)
          Facter::Core::Execution.expects(:execute).with(ipa_env_server_query, ipa_query_options).returns(ipa_server_env)
          expect(Facter.fact('ipa').value).to eq({
            'connected' => true,
            'domain'    => 'example.com',
            'server'    => 'ipaserver.example.com',
            'realm'     => 'EXAMPLE.COM',
            'basedn'    => 'dc=example,dc=com'
          })
        end
      end
    end

    context 'IPA server is not available' do
      it 'should return defaults from /etc/ipa/default.conf and disconnected status' do
        Facter::Core::Execution.expects(:which).with('kinit').returns('/usr/bin/kinit')
        Facter::Core::Execution.expects(:which).with('ipa').returns('/usr/bin/ipa')
        File.expects(:exist?).with('/etc/ipa/default.conf').returns(true)
        File.expects(:read).with('/etc/ipa/default.conf').returns(default_conf)
        Facter::Core::Execution.expects(:execute).with('/usr/bin/kinit -k 2>&1', kinit_query_options).returns('some error message')
        Facter::Core::Execution.expects(:execute).twice.with(ipa_env_query, ipa_query_options).returns('')
        expect(Facter.fact('ipa').value).to eq({
          'connected' => false,
          'domain'    => 'example.com',
          'server'    => 'ipaserver.example.com',
          'realm'     => 'EXAMPLE.COM',
          'basedn'    => 'dc=example,dc=com'
        })
      end
    end
  end
end
