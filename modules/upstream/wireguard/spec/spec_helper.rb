require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'

include RspecPuppetFacts

require 'simplecov'
require 'simplecov-console'

SimpleCov.start do
  add_filter '/spec'
  add_filter '/vendor'
  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Console
  ])
end

RSpec.configure do |c|
  # getting the correct facter version is tricky. We use facterdb as a source to mock facts
  # see https://github.com/camptocamp/facterdb
  # people might provide a specific facter version. In that case we use it.
  # Otherwise we need to match the correct facter version to the used puppet version.
  # as of 2019-10-31, puppet 5 ships facter 3.11 and puppet 6 ships facter 3.14
  # https://puppet.com/docs/puppet/5.5/about_agent.html
  c.default_facter_version = if ENV['FACTERDB_FACTS_VERSION']
                               ENV['FACTERDB_FACTS_VERSION']
                             else
                               Gem::Dependency.new('', ENV['PUPPET_VERSION']).match?('', '5') ? '3.11.0' : '3.14.0'
                             end

  c.hiera_config = File.expand_path(File.join(__FILE__, '../fixtures/hiera.yaml'))
end
