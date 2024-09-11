require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet_blacksmith/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

exclude_paths = [
  'pkg/**/*',
  'spec/**/*',
  'vendor/**/*',
]

# Puppet-Lint 1.1.0
Rake::Task[:lint].clear
PuppetLint::RakeTask.new :lint do |config|
  config.disable_checks = ['80chars', 'class_inherits_from_params_class']
  config.fail_on_warnings = true
  config.ignore_paths = exclude_paths
end
# Puppet-Lint 1.1.0 as well ...
PuppetLint.configuration.relative = true

PuppetSyntax.exclude_paths = exclude_paths

task :test => [
  :syntax,
  :lint,
  :spec,
]
