require 'spec_helper'
require 'puppet/property/boolean'

describe Puppet::Property::Boolean do
  subject { described_class.new(resource: resource) }

  let(:resource) { mock('resource') }

  [true, :true, 'true', :yes, 'yes'].each do |arg|
    it "should munge #{arg.inspect} as true" do
      subject.munge(arg).should == true
    end
  end
  [:absent, false, :false, 'false', :no, 'no', :undef, nil].each do |arg|
    it "should munge #{arg.inspect} as false" do
      subject.munge(arg).should == false
    end
  end
  ['undef', 'nil', '0', 0, '1', 1, 9284].each do |arg|
    it "should fail to munge #{arg.inspect}" do
      expect { subject.munge(arg) }.to raise_error ArgumentError
    end
  end
  it "fail to munge 'woof' with a specific message" do
    expect { subject.munge('woof') }.to raise_error ArgumentError, %r{Value 'woof':String cannot be determined as a boolean value}
  end
end
