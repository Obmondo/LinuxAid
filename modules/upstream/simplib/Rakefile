require 'simp/rake/pupmod/helpers'
require 'puppet-strings/tasks'

Simp::Rake::Pupmod::Helpers.new(File.dirname(__FILE__))

# Standard 'acceptance' Rake task does not work, because it does not
# use the suite-specific nodeset YAML files. 
desc 'Run acceptance tests'
Rake::Task[:acceptance].clear
RSpec::Core::RakeTask.new(:acceptance) do |t|
  Rake::Task['beaker:suites'].invoke
end


