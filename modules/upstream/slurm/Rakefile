##############################################################################
# Rakefile - Configuration file for rake (http://rake.rubyforge.org/)
# Time-stamp: <Tue 2024-08-27 16:23:01 hcartiaux>
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
require 'puppet_litmus/rake_tasks' if Gem.loaded_specs.key? 'puppet_litmus'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-syntax/tasks/puppet-syntax'

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

require 'puppet-strings/tasks' if Gem.loaded_specs.key? 'puppet-strings'

PuppetLint.configuration.send('disable_relative')
