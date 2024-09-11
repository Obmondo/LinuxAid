require 'spec_helper'


describe "defaultgateway" do
  before :each do
    Facter.clear
  end

  let(:ipv4route) { <<EOM
192.168.221.0/24 dev eth0  proto kernel  scope link  src 192.168.221.200 
169.254.0.0/16 dev eth0  scope link  metric 1002 
default via 192.168.221.1 dev eth0 
EOM
  }

  context 'ip command exists' do
    before :each do
      Facter::Core::Execution.stubs(:exec).with('uname -s').returns('Linux')
      Facter::Util::Resolution.stubs(:which).with('ip').returns('/usr/bin/ip')
    end

    it 'returns IP address of valid default route' do
      Facter::Core::Execution.stubs(:exec).with('/usr/bin/ip route').returns(ipv4route)
      expect(Facter.fact(:defaultgateway).value).to eq('192.168.221.1')
    end

    it 'returns IP address of last valid default route' do
      multiple_defaults = ipv4route + "default via 10.0.2.1 dev eth1"
      Facter::Core::Execution.stubs(:exec).with('/usr/bin/ip route').returns(multiple_defaults)
      expect(Facter.fact(:defaultgateway).value).to eq('10.0.2.1')
    end

    it "returns 'unknown' when no default line exists" do
      bad_route = ipv4route.gsub('default', 'oops ')
      Facter::Core::Execution.stubs(:exec).with('/usr/bin/ip route').returns(bad_route)
      expect(Facter.fact(:defaultgateway).value).to eq('unknown')
    end

    it "returns 'unknown' when IP address could not be extracted from the default line" do
      bad_route = ipv4route.gsub('default via 192.168.221.1 ', 'default via some.fqdn ')
      Facter::Core::Execution.stubs(:exec).with('/usr/bin/ip route').returns(bad_route)
      expect(Facter.fact(:defaultgateway).value).to eq('unknown')
    end
  end

  context 'ip command does not exist' do
    it "returns 'unknown'" do
      Facter::Util::Resolution.stubs(:which).with('ip').returns(nil)
      expect(Facter.fact(:defaultgateway).value).to eq('unknown')
    end
  end
end
