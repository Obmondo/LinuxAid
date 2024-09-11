require 'spec_helper'

describe command("su -l root -c 'vagrant box list'") do
  its(:stdout) { should match /^puppetlabs\/centos-6.6-64-puppet/ }
end
