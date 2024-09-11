require 'spec_helper'

describe 'cmdline' do
  before :each do
    Facter.clear
  end

  let(:unique_line) {
    'root=/dev/mapper/VolGroup00-RootVol ro console=ttyS1,57600 rd.lvm.lv=VolGroup00/RootVol rhgb quiet rd.shell=0'
  }
  let(:dup_line) {
    'root=/dev/mapper/VolGroup00-RootVol ro console=ttyS1,57600 rd.lvm.lv=VolGroup00/RootVol rd.lvm.lv=VolGroup00/SwapVol rhgb quiet rd.shell=0'
  }

  context '/proc/cmdline exists' do
    it 'and has no duplicate entries' do
      File.stubs(:read).with('/proc/cmdline').returns(unique_line)
      expect(Facter.fact(:cmdline).value).to eq({
        'root'      => '/dev/mapper/VolGroup00-RootVol',
        'ro'        => nil,
        'console'   => 'ttyS1,57600',
        'rd.lvm.lv' => 'VolGroup00/RootVol',
        'rhgb'      => nil,
        'quiet'     => nil,
        'rd.shell'  => '0'
      })
    end

    it 'and has duplicate entries' do
      File.stubs(:read).with('/proc/cmdline').returns(dup_line)
      expect(Facter.fact(:cmdline).value).to eq({
        'root'      => '/dev/mapper/VolGroup00-RootVol',
        'ro'        => nil,
        'console'   => 'ttyS1,57600',
        'rd.lvm.lv' => [
          'VolGroup00/RootVol',
          'VolGroup00/SwapVol'
        ],
        'rhgb'      => nil,
        'quiet'     => nil,
        'rd.shell'  => '0'
      })
    end
  end

  context '/proc/cmdline does not exist' do
    it 'returns nil' do
      Facter::Util::Resolution.stubs(:which).with('ip').returns(nil)
      expect(Facter.fact(:defaultgateway).value).to eq('unknown')
    end
  end
end
