require 'spec_helper'

describe 'cassandraminorversion' do
  before { Facter.clear }
  after { Facter.clear }

  describe 'cassandrarelease DSE' do
    it do
      Facter::Util::Resolution.stubs(:exec).with('nodetool version').returns('2.1.11.969')
      expect(Facter.fact(:cassandraminorversion).value).to be(1)
    end
  end

  describe 'cassandrarelease DDC' do
    it do
      Facter::Util::Resolution.stubs(:exec).with('nodetool version').returns('3.0.1')
      expect(Facter.fact(:cassandraminorversion).value).to be(0)
    end
  end

  describe 'Cassandra not installed or not running' do
    it do
      Facter::Util::Resolution.stubs(:exec).with('nodetool version').returns('')
      expect(Facter.fact(:cassandraminorversion).value).to be(nil)
    end
  end
end
