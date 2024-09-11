require 'rubygems'
require 'bundler/setup'

Bundler.require :default

require 'rspec/core/rake_task'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet_blacksmith/rake_tasks'

require 'puppet-lint/tasks/puppet-lint'
PuppetLint.configuration.ignore_paths = [ 'vendor/**/*.pp' ]

require 'metadata-json-lint/rake_task'

task :default do
  sh %{rake -T}
end

desc 'Run spec and lint'
task :ci => [
  :metadata_lint,
  :lint,
  :spec,
  :syntax,
  :validate,
]
