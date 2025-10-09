require 'simp/rake/pupmod/helpers'
require 'puppet-strings/tasks'

Simp::Rake::Pupmod::Helpers.new(File.dirname(__FILE__))

task :spec_clean do
  FileUtils.rm_rf('spec/fixtures/inspec/inspec_deps')
end
