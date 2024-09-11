require 'rubygems'
require 'rake'
require 'bundler'
require 'rspec/core/rake_task'
require 'puppetlabs_spec_helper/rake_tasks'

begin
  Bundler.setup(:default)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end