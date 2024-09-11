require 'spec_helper'

describe package('vagrant') do
  it { should be_installed }
end

describe command('vagrant --version') do
  its(:stdout) { should match /Vagrant 1.6.3/ }
end
