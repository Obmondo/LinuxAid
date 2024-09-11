##############################################################################
# Rakefile - Configuration file for rake (http://rake.rubyforge.org/)
# Time-stamp: <Thu 2022-06-30 14:43 svarrette>
#
# Copyright (c) 2017  UL HPC Team <hpc-sysadmins@uni.lu>
#                       ____       _         __ _ _
#                      |  _ \ __ _| | _____ / _(_) | ___
#                      | |_) / _` | |/ / _ \ |_| | |/ _ \
#                      |  _ < (_| |   <  __/  _| | |  __/
#                      |_| \_\__,_|_|\_\___|_| |_|_|\___|
#
# Use 'rake -T' to list the available actions
#
# Resources:
# * http://www.stuartellis.eu/articles/rake/
#
# See also https://github.com/garethr/puppet-module-skeleton
##############################################################################
require 'falkorlib'

# frozen_string_literal: true
require 'bundler'
require 'puppet_litmus/rake_tasks' if Bundler.rubygems.find_name('puppet_litmus').any?
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppet_blacksmith/rake_tasks' if Bundler.rubygems.find_name('puppet-blacksmith').any?
require 'github_changelog_generator/task' if Bundler.rubygems.find_name('github_changelog_generator').any?
require 'puppet-strings/tasks' if Bundler.rubygems.find_name('puppet-strings').any?

## placeholder for custom configuration of FalkorLib.config.*
## See https://github.com/Falkor/falkorlib

# Adapt the versioning aspects
FalkorLib.config.versioning do |c|
    c[:type] = 'puppet_module'
end

# Adapt the Git flow aspects
FalkorLib.config.gitflow do |c|
    c[:branches] = {
        :master  => 'production',
        :develop => 'devel'
    }
end

desc "Update changelog using gitchangelog https://pypi.org/project/gitchangelog/"
task :gitchangelog do |t|
  info "#{t.comment}"
  run %{gitchangelog > CHANGELOG.md}
  info "=> about to commit changes in CHANGELOG.md"
  really_continue?
  FalkorLib::Git.add('CHANGELOG.md', 'Synchronize Changelog with latest commits')
end
namespace :pdk do
  ##### pdk:{build,validate} ####
  [ 'build', 'validate'].each do |action|
    desc "Run pdk #{action}"
    task action.to_sym do |t|
      info "#{t.comment}"
      run %{pdk #{action}}
    end
  end
end # namespace pdk

###########   up   ###########
desc "Update your local branches"
task :up do |t|
    info "#{t.comment}"
    FalkorLib::Git.fetch
    branches = FalkorLib::Git.list_branch
    #puts branches.to_yaml
    unless FalkorLib::Git.dirty?
        FalkorLib.config.gitflow[:branches].each do |t, br|
            info "updating Git Flow #{t} branch '#{br}' with the 'origin' remote"
            run %{ git checkout #{br} && git merge origin/#{br} }
        end
        run %{ git checkout #{branches[0]} }  # Go back to the initial branch
    else
        warning "Unable to update -- your local repository copy is dirty"
    end

end # task up

require 'falkorlib/tasks/git'

task 'validate' => 'pdk:validate'
%w(major minor patch).each do |level|
  task "version:bump:#{level}" => 'validate'
end
Rake::Task["version:release"].enhance do
  Rake::Task["gitchangelog"].invoke
  Rake::Task["pdk:build"].invoke
end


def changelog_user
  return unless Rake.application.top_level_tasks.include? "changelog"
  returnVal = nil || JSON.load(File.read('metadata.json'))['author']
  raise "unable to find the changelog_user in .sync.yml, or the author in metadata.json" if returnVal.nil?
  puts "GitHubChangelogGenerator user:#{returnVal}"
  returnVal
end

def changelog_project
  return unless Rake.application.top_level_tasks.include? "changelog"

  returnVal = nil
  returnVal ||= begin
    metadata_source = JSON.load(File.read('metadata.json'))['source']
    metadata_source_match = metadata_source && metadata_source.match(%r{.*\/([^\/]*?)(?:\.git)?\Z})

    metadata_source_match && metadata_source_match[1]
  end

  raise "unable to find the changelog_project in .sync.yml or calculate it from the source in metadata.json" if returnVal.nil?

  puts "GitHubChangelogGenerator project:#{returnVal}"
  returnVal
end

def changelog_future_release
  return unless Rake.application.top_level_tasks.include? "changelog"
  returnVal = "v%s" % JSON.load(File.read('metadata.json'))['version']
  raise "unable to find the future_release (version) in metadata.json" if returnVal.nil?
  puts "GitHubChangelogGenerator future_release:#{returnVal}"
  returnVal
end

exclude_paths = %w(
  pkg/**/*
  vendor/**/*
  .vendor/**/*
  spec/**/*
  tests/vagrant/**/*
)
PuppetLint.configuration.ignore_paths = exclude_paths
PuppetSyntax.exclude_paths = exclude_paths
# PuppetLint.configuration.send('disable_relative')
# PuppetLint.configuration.send('disable_manifest_whitespace_closing_brace_before')



if Bundler.rubygems.find_name('github_changelog_generator').any?
  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    raise "Set CHANGELOG_GITHUB_TOKEN environment variable eg 'export CHANGELOG_GITHUB_TOKEN=valid_token_here'" if Rake.application.top_level_tasks.include? "changelog" and ENV['CHANGELOG_GITHUB_TOKEN'].nil?
    config.user = "#{changelog_user}"
    config.project = "#{changelog_project}"
    config.future_release = "#{changelog_future_release}"
    config.exclude_labels = ['maintenance']
    config.header = "# Change log\n\nAll notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org)."
    config.add_pr_wo_labels = true
    config.issues = false
    config.merge_prefix = "### UNCATEGORIZED PRS; LABEL THEM ON GITHUB"
    config.configure_sections = {
      "Changed" => {
        "prefix" => "### Changed",
        "labels" => ["backwards-incompatible"],
      },
      "Added" => {
        "prefix" => "### Added",
        "labels" => ["enhancement", "feature"],
      },
      "Fixed" => {
        "prefix" => "### Fixed",
        "labels" => ["bug", "documentation", "bugfix"],
      },
    }
  end
else
  desc 'Generate a Changelog from GitHub'
  task :changelog do
    raise <<EOM
The changelog tasks depends on recent features of the github_changelog_generator gem.
Please manually add it to your .sync.yml for now, and run `pdk update`:
---
Gemfile:
  optional:
    ':development':
      - gem: 'github_changelog_generator'
        version: '~> 1.15'
        condition: "Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.3.0')"
EOM
  end
end
