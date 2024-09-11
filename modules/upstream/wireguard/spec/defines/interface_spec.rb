require 'spec_helper'

describe 'wireguard::interface', :type => :define do
  let(:title) { 'wg0' }
  let(:pre_condition) { 'include wireguard' }
  let :default_params do
    {
      'address'     => [
        '1.1.1.1/24',
        '2.2.2.2/24'
      ],
      'private_key' => 'privatekey',
      'listen_port' => 52980,
      'ensure'      => 'present',
      'postup'      => [
          'foo',
          'bar',
      ],
      'postdown'    => 'baz',
      'peers'       => [
        {
          'Comment'    => 'foo',
          'PublicKey'  => 'publickey1',
          'AllowedIPs' => '1.1.1.2',
        },
        {
          'PublicKey'    => 'publickey2',
          'AllowedIPs'   => '1.1.1.3',
          'Endpoint'     => '3.3.3.3:12345',
          'PresharedKey' => 'output_from_wg_genpsk',
          'Comment'      => 'bar baz',
        },
      ],
      'mtu'         => 123,
      'saveconfig'  => true,
      'config_dir'  => '/etc/wireguard'
    }
  end
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "wireguard::interface define without any parameters" do
          it do
            expect { should compile.with_all_deps }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
          end
        end
        context "wireguard::interface define with parameters" do
          let (:params) do
            default_params
          end
          it { is_expected.to compile.with_all_deps }
          it do
            is_expected.to contain_file('/etc/wireguard/wg0.conf').with({
            'ensure'  => 'present',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0600',
            'content' => '# This file is managed by puppet
[Interface]
Address = 1.1.1.1/24
Address = 2.2.2.2/24
SaveConfig = true
PrivateKey = privatekey
ListenPort = 52980
MTU = 123
PostUp = foo
PostUp = bar
PostDown = baz

# Peers
[Peer]
# foo
PublicKey = publickey1
AllowedIPs = 1.1.1.2

[Peer]
PublicKey = publickey2
AllowedIPs = 1.1.1.3
Endpoint = 3.3.3.3:12345
PresharedKey = output_from_wg_genpsk
# bar baz

'
          })
          end
        end
        context 'wireguard::interface define without an address' do
          let (:params) do
            default_params.reject { |key, _| key == 'address' }
          end
          it { is_expected.to compile.with_all_deps }
          it do
            is_expected.to contain_file('/etc/wireguard/wg0.conf')
              .without_content(%r{Address})
          end
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'libreswan::define define without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          :osfamily        => 'Solaris',
          :operatingsystem => 'Nexenta',
        }
      end
      it do 
        expect { should compile.with_all_deps }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end
  end
end
