require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppet_blacksmith/rake_tasks'
require 'bundler'
require 'rake/clean'

exclude_paths = [
  "pkg/**/*",
  "vendor/**/*",
  "spec/**/*",
  "test/**/*"
]

CLEAN.include('spec/fixtures/')
CLOBBER.include('.tmp', '.librarian', 'Puppetfile.lock', 'spec/fixtures/modules')

PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"
PuppetLint.configuration.send("disable_80chars")
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.send("disable_autoloader_layout")
PuppetLint.configuration.send("disable_quoted_booleans")
PuppetLint.configuration.ignore_paths = exclude_paths
PuppetSyntax.exclude_paths = exclude_paths

task :librarian_spec_prep do
   sh "librarian-puppet install --path spec/fixtures/modules"
end

task :spec_prep => :librarian_spec_prep
task :validate => :syntax
task :default => [:spec, :lint]

desc "Run integration tests"
task :integration do
  sh "kitchen test all --destroy=always --parallel"
end

desc "Set patch version in metadata.json based on env var TRAVIS_BUILD_NUMBER"
task :set_travis_version do
  require 'json'
  travis_build_number = ENV['TRAVIS_BUILD_NUMBER']
  metadata_json = File.read('metadata.json')
  data_hash = JSON.parse(metadata_json)
  version = data_hash["version"]
  new_version = "#{version.split(".")[0,2].join(".")}.#{travis_build_number}"
  data_hash["version"] = new_version
  File.open('metadata.json', 'w') do |f|
    f.write(JSON.pretty_generate(data_hash))
  end
  puts "Travis build number: #{travis_build_number}"
  puts "New version: #{new_version}"
end
