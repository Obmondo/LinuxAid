require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

task :test => [:lint, :syntax, :spec]

task :default => :test

exclude_paths = [
  "pkg/**/*",
  "vendor/**/*",
  "spec/**/*",
]
Rake::Task[:lint].clear
PuppetLint::RakeTask.new :lint do |config|
  config.disable_checks = ['80chars', 'autoloader_layout']
  config.ignore_paths = exclude_paths
end
