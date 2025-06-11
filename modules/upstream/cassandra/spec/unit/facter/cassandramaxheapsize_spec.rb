require 'spec_helper'

describe ':cassandramaxheapsize' do
  before { Facter.clear }
  after { Facter.clear }

  describe 'Heap settings' do
    describe 'Rasberry Pi 3' do
      it do
        Facter.fact(:memorysize_mb).stubs(:value).returns('1024')
        Facter.fact(:processorcount).stubs(:value).returns('4')
        expect(Facter.fact(:cassandramaxheapsize).value).to eq(512)
      end
    end

    describe 'm4.large' do
      it do
        Facter.fact(:memorysize_mb).stubs(:value).returns('8191.9')
        Facter.fact(:processorcount).stubs(:value).returns('2')
        expect(Facter.fact(:cassandramaxheapsize).value).to be(2048)
      end
    end

    describe 'm4.xlarge' do
      it do
        Facter.fact(:memorysize_mb).stubs(:value).returns('16384')
        Facter.fact(:processorcount).stubs(:value).returns('2')
        expect(Facter.fact(:cassandramaxheapsize).value).to be(4096)
      end
    end

    describe 'c4.2xlarge' do
      it do
        Facter.fact(:memorysize_mb).stubs(:value).returns('15360')
        Facter.fact(:processorcount).stubs(:value).returns('8')
        expect(Facter.fact(:cassandramaxheapsize).value).to be(3840)
      end
    end

    describe 'i2.2xlarge' do
      it do
        Facter.fact(:memorysize_mb).stubs(:value).returns('62464')
        Facter.fact(:processorcount).stubs(:value).returns('8')
        expect(Facter.fact(:cassandramaxheapsize).value).to be(8192)
      end
    end
  end
end
