require 'rake'
require 'rspec/core/rake_task'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint'

PuppetLint.configuration.send("disable_80chars")
PuppetLint.configuration.ignore_paths = ["pkg/**/*.pp"]
