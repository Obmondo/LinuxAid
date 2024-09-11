require 'spec_helper'

describe 'fips_ciphers' do

  before :each do
    Facter.clear
    Facter::Core::Execution.stubs(:exec).with('uname -s').returns('Linux')
  end

  context 'openssl command exists' do
    it 'returns FIPS ciphers' do
      Facter::Core::Execution.stubs(:which).with('openssl').returns('/bin/openssl')
      Facter::Core::Execution.stubs(:exec).with('/bin/openssl ciphers FIPS:-LOW').returns("ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA")
      expect(Facter.fact('fips_ciphers').value).to eq(["ECDHE-RSA-AES256-GCM-SHA384","ECDHE-ECDSA-AES256-GCM-SHA384","ECDHE-RSA-AES256-SHA384","ECDHE-ECDSA-AES256-SHA384","ECDHE-RSA-AES256-SHA"])
    end
  end

  context 'openssl command does not exist' do
    it 'returns nil' do
      Facter::Core::Execution.stubs(:which).with('openssl').returns(nil)
      expect(Facter.fact('fips_ciphers').value).to eq(nil)
    end
  end

end
