require 'spec_helper'

describe "simplib__firewalls" do

  before :each do
    Facter.clear

    Facter::Util::Resolution.expects(:which).with('firewalld').returns('/usr/bin/firewalld')
    Facter::Util::Resolution.expects(:which).with('nft').returns('/usr/bin/nft')
    Facter::Util::Resolution.expects(:which).with('pfctl').returns('/bin/pfctl')
    Facter::Util::Resolution.stubs(:which).with(Not(any_of('firewalld','nft','pfctl')))
  end

  it { expect(Facter.fact('simplib__firewalls').value).to eq(['firewalld','nft','pf']) }
end
