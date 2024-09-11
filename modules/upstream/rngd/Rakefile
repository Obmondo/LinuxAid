require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'rake/clean'
require 'metadata-json-lint/rake_task'
require 'puppet-strings/tasks'

CLEAN.include('spec/fixtures/manifests', 'spec/fixtures/modules')
CLOBBER.include('.tmp', '.librarian', '.vagrant', 'Puppetfile.lock', 'log', 'junit', 'coverage', 'doc')

task :spec => []; Rake::Task[:spec].clear
task :spec do
  Rake::Task[:spec_prep].invoke
  Rake::Task[:spec_standalone].invoke
end

task :librarian_spec_prep do
  sh 'librarian-puppet install --path=spec/fixtures/modules/'
end
task :spec_prep => :librarian_spec_prep

task :test => [
  'metadata_lint',
  'syntax',
  'spec',
  'lint',
]

PuppetLint.configuration.log_format = '%{path}:%{line}:%{check}:%{KIND}:%{message}'
PuppetLint.configuration.ignore_paths = ['pkg/**/*.pp', 'spec/**/*.pp', 'vendor/**/*.pp']
PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.relative = true
PuppetLint.configuration.send('disable_class_inherits_from_params_class')

PuppetSyntax.exclude_paths = ['pkg/**/*', 'spec/**/*', 'vendor/**/*']
