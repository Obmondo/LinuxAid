require 'spec_helper'

describe command("su -l root -c 'vagrant plugin list'") do
  its(:stdout) { should match /^vagrant-puppet-install/ }
end
