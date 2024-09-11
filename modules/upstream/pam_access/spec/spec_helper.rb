require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

RSpec.configure do |c|
  c.formatter = :documentation
end
