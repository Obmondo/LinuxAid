require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    hosts.each do |host|
      # Install module and dependencies
      copy_module_to(host, source: proj_root, module_name: 'curator')

      on host, puppet('module', 'install', 'puppetlabs/stdlib'), acceptable_exit_codes: [0, 1]
      on host, puppet('module', 'install', 'stankevich/python'), acceptable_exit_codes: [0, 1]

      if fact('osfamily') == 'RedHat'
        on host, puppet('module', 'install', 'stahnma/epel'), acceptable_exit_codes: [0, 1]
      end
    end
  end
end
