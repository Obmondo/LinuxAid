# frozen_string_literal: true

# Make sure bolt's puppet is loaded
require 'bolt/pal'
require 'voxpupuli/acceptance/spec_helper_acceptance'
Bolt::PAL.load_puppet

require 'beaker-rspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'
require 'voxpupuli/acceptance/spec_helper_acceptance'

UNSUPPORTED_PLATFORMS = ['Solaris', 'AIX'].freeze

base_dir = File.dirname(File.expand_path(__FILE__))

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # should we just use rspec_puppet
  c.add_setting :module_path
  c.module_path = File.join(base_dir, 'fixtures', 'modules')
end
