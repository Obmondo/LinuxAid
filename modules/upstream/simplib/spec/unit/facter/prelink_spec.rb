require 'spec_helper'

describe "custom fact prelink" do
  let (:sysconfig_prelink_enabled) { <<EOM
# Set this to no to disable prelinking altogether
PRELINKING=yes
PRELINK_OPTS=-mR
EOM
  }

  let (:sysconfig_prelink_disabled) { <<EOM
# Set this to no to disable prelinking altogether
PRELINKING=no
PRELINK_OPTS=-mR
EOM
  }

  let (:sysconfig_prelink_unspecified) { <<EOM
# Set this to no to disable prelinking altogether
#PRELINKING=yes
PRELINK_OPTS=-mR
EOM
  }

  before(:each) do
    Facter.clear

    # mock out Facter method called when evaluating confine for :kernel
    Facter::Core::Execution.stubs(:exec).with('uname -s').returns('Linux')
  end

  context '/etc/sysconfig/prelink enables prelinking' do
    it 'should return hash with enabled status' do
      Facter::Core::Execution.expects(:which).with('prelink').returns('/usr/sbin/prelink')
      File.expects(:exist?).with('/etc/sysconfig/prelink').returns(true)
      File.expects(:read).with('/etc/sysconfig/prelink').returns(sysconfig_prelink_enabled)

      expect(Facter.fact('prelink').value).to eq({ 'enabled' => true })
    end
  end

  context '/etc/sysconfig/prelink disables prelinking' do
    it 'should return hash with disabled status' do
      Facter::Core::Execution.expects(:which).with('prelink').returns('/usr/sbin/prelink')
      File.expects(:exist?).with('/etc/sysconfig/prelink').returns(true)
      File.expects(:read).with('/etc/sysconfig/prelink').returns(sysconfig_prelink_disabled)
      expect(Facter.fact('prelink').value).to eq({ 'enabled' => false })
    end
  end

  context '/etc/sysconfig/prelink does not specify prelinking action' do
    it 'should return hash with disabled status' do
      Facter::Core::Execution.expects(:which).with('prelink').returns('/usr/sbin/prelink')
      File.expects(:exist?).with('/etc/sysconfig/prelink').returns(true)
      File.expects(:read).with('/etc/sysconfig/prelink').returns(sysconfig_prelink_unspecified)
      expect(Facter.fact('prelink').value).to eq({ 'enabled' => false })
    end
  end

  context '/etc/sysconfig/prelink is absent' do
    it 'should return hash with disabled status' do
      Facter::Core::Execution.expects(:which).with('prelink').returns('/usr/sbin/prelink')
      File.expects(:exist?).with('/etc/sysconfig/prelink').returns(false)
      expect(Facter.fact('prelink').value).to eq({ 'enabled' => false })
    end
  end

  context 'prelink executable is not available' do
    it 'should return nil' do
      Facter::Core::Execution.expects(:which).with('prelink').returns(nil)

      expect(Facter.fact('prelink').value).to be nil
    end
  end
end
