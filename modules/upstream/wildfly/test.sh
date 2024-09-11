#!/bin/bash

source ~/.profile
source ~/.rvm/scripts/rvm

rvm --version

# rvm install ruby-1.8.7
# rvm use ruby-1.8.7
# rvm install ruby-1.9.3
# rvm use ruby-1.9.3
rvm install ruby-2.0.0
rvm use ruby-2.0.0

set -e

ruby -v
echo "gem version"
gem --version
gem install bundler --no-rdoc --no-ri --version 1.10.6
bundle install --without development
bundle --version
gem update --system 2.1.11

bundle exec rake syntax
bundle exec rake lint
bundle exec rake spec
#bundle exec rake ci:setup:rspec spec
BEAKER_debug=true BEAKER_destroy=onpass bundle exec rspec spec/acceptance
BEAKER_set=centos-70-x64 bundle exec rspec spec/acceptance
BEAKER_set=debian-78-x64 bundle exec rspec spec/acceptance
bundle exec rubocop
#bundle exec rake spec

#ruby syntax check
rubocop


# Release the Puppet module, doing a clean, build, tag, push, bump_commit
rake module:clean
rake build

rake module:push
rake module:tag
rake module:bump_commit  # Bump version and git commit


## Windows

start cmd in admin mode

use only 32-bits, its more stable, http://rubyinstaller.org/downloads/

Ruby 2.0.0-p598 to C:\Ruby\200
Ruby Development kit to C:\Ruby\2_devkit, so you can optionally build your gems

set PATH=%PATH%;C:\Ruby\200\bin
C:\Ruby\2_devkit\devkitvars.bat
ruby -v

### Gem

#### one time rubygems ssl error
https://github.com/rubygems/rubygems/releases/tag/v2.0.15
gem install --local C:\temp\rubygems-update-2.0.15.gem
update_rubygems --no-ri --no-rdoc
gem uninstall rubygems-update -x

gem update --system 2.1.11
gem list --local
gem uninstall bundler
gem install bundler --version 1.7.15
gem install json

### Bundle

bundle install --verbose --without development

bundle exec rake syntax
bundle exec rake lint
bundle exec rake spec
bundle exec rubocop

bundle exec rspec spec/acceptance
BEAKER_set=centos-70-x64 bundle exec rspec spec/acceptance
BEAKER_destroy=onpass BEAKER_set=debian-78-x64 bundle exec rspec spec/acceptance
