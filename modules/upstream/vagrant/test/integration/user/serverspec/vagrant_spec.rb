require 'spec_helper'

describe user('foobar_user') do
  it { should exist }
  it { should belong_to_group 'foobar_group' }
end

describe group('foobar_group') do
  it { should exist }
end

describe command('/tmp/teardown.sh') do
  its(:exit_status) { should eq 0}
end

describe user('foobar_user') do
  it { should_not exist }
  it { should_not belong_to_group 'foobar_group' }
end

describe group('foobar_group') do
  it { should_not exist }
end
