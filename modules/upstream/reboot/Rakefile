# frozen_string_literal: true

require 'bundler'
require 'puppet_litmus/rake_tasks' if Gem.loaded_specs.key? 'puppet_litmus'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppet-strings/tasks' if Gem.loaded_specs.key? 'puppet-strings'

PuppetLint.configuration.send('disable_relative')

if Rake::Task.task_defined?('spec_prep')
  Rake::Task.tasks.each do |task|
    next unless task.name.start_with? 'litmus:acceptance'
    task.enhance([Rake::Task['spec_prep']])
  end
end

