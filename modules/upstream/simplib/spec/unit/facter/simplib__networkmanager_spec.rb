require 'spec_helper'

describe 'simplib__networkmanager' do

  before :each do
    Facter.clear
    Facter::Core::Execution.stubs(:exec).with('uname -s').returns('Linux')
    Facter::Util::Resolution.stubs(:which).with('nmcli').returns('/usr/sbin/nmcli')

    Facter::Core::Execution.stubs(:execute).with('/usr/sbin/nmcli -t -m multiline general status', :on_fail => :failed).returns(general_status)
    Facter::Core::Execution.stubs(:execute).with('/usr/sbin/nmcli -t general hostname', :on_fail => :failed).returns(general_hostname)
    Facter::Core::Execution.stubs(:execute).with('/usr/sbin/nmcli -t connection show', :on_fail => :failed).returns(connections)
  end

  context 'nmcli fails' do
    let(:general_status){ :failed }
    let(:general_hostname){ :failed }
    let(:connections){ :failed }

    it 'returns "enabled" = false' do
      expect(Facter.fact('simplib__networkmanager').value).to eq({'enabled' => false})
    end
  end

  context 'nmcli succeeds' do
    let(:general_status){
      <<-EOM
STATE:connected
CONNECTIVITY:full
WIFI-HW:enabled
WIFI:enabled
WWAN-HW:enabled
WWAN:enabled
      EOM
    }

    let(:general_hostname){ "foo.bar.baz\n" }

    let(:connections){
      <<-EOM
Eth Dev:b961cb37-ae05-4c67-98b0-432465fe03c2:802-3-ethernet:eth0
Bridge Dev:0c190f3f-262b-4585-a7de-2a146896ea86:bridge:virbr0
      EOM
    }

    let(:expected){{
      'enabled'    => true,
      'general'    => {
        'hostname' => general_hostname.strip,
        'status'   => {
          'STATE'        => 'connected',
          'CONNECTIVITY' => 'full',
          'WIFI-HW'      => 'enabled',
          'WIFI'         => 'enabled',
          'WWAN-HW'      => 'enabled',
          'WWAN'         => 'enabled'
        },
      },
      'connection' => {
        'eth0'   => {
          'uuid' => 'b961cb37-ae05-4c67-98b0-432465fe03c2',
          'type' => '802-3-ethernet',
          'name' => 'Eth Dev'
        },
        'virbr0' => {
          'uuid' => '0c190f3f-262b-4585-a7de-2a146896ea86',
          'type' => 'bridge',
          'name' => 'Bridge Dev'
        }
      }
    }}

    it 'is enabled' do
      expect(Facter.fact('simplib__networkmanager').value).to eq(expected)
    end
  end
end
