require 'spec_helper'

describe 'cassandraheapnewsize' do
  before { Facter.clear }
  after { Facter.clear }

  describe 'Heap settings' do
    describe 'Rasberry Pi 3' do
      it do
        Facter.fact(:memorysize_mb).stubs(:value).returns('1024')
        Facter.fact(:processorcount).stubs(:value).returns('4')
        expect(Facter.fact(:cassandraheapnewsize).value).to be(128)
      end
    end

    describe 'm4.large' do
      it do
        Facter.fact(:memorysize_mb).stubs(:value).returns('8191.9')
        Facter.fact(:processorcount).stubs(:value).returns('2')
        expect(Facter.fact(:cassandraheapnewsize).value).to be(200)
      end
    end

    describe 'm4.xlarge' do
      it do
        Facter.fact(:memorysize_mb).stubs(:value).returns('16384')
        Facter.fact(:processorcount).stubs(:value).returns('2')
        expect(Facter.fact(:cassandraheapnewsize).value).to be(200)
      end
    end

    describe 'c4.2xlarge' do
      it do
        Facter.fact(:memorysize_mb).stubs(:value).returns('15360')
        Facter.fact(:processorcount).stubs(:value).returns('8')
        expect(Facter.fact(:cassandraheapnewsize).value).to be(800)
      end
    end

    describe 'i2.2xlarge' do
      it do
        Facter.fact(:memorysize_mb).stubs(:value).returns('62464')
        Facter.fact(:processorcount).stubs(:value).returns('8')
        expect(Facter.fact(:cassandraheapnewsize).value).to be(800)
      end
    end
  end
end
