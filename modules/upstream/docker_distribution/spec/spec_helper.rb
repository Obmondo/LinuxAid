require 'rubygems'

require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

RSpec.configure do |config|
  config.mock_with :rspec do |c|
    c.syntax = :expect
  end
end
