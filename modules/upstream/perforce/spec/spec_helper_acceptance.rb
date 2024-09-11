#! /usr/bin/env ruby -S rspec
require 'puppet'
require 'beaker-rspec'
require 'beaker-puppet'
require 'beaker/module_install_helper'
require 'pry'

install_puppet_agent_on(hosts)
install_module_dependencies_on(hosts)

# Install module and dependencies
install_dev_puppet_module(modulename: 'perforce')

RSpec.configure do |c|
  c.formatter = :documentation
end
