# THIS FILE IS CENTRALLY MANAGED BY sync_spec.rb!
# DO NOT EDIT IT HERE!

source "https://rubygems.org"

group :tests do
  gem "puppetlabs_spec_helper", :require => false
  gem "rspec-puppet-utils", :require => false
  gem "metadata-json-lint", :require => false
  gem "puppet-blacksmith",  :require => false
  gem "puppet-strings",  :require => false
  gem "CFPropertyList",  :require => false
  gem "rubocop-rspec",   :require => false
  gem "rubocop",         :require => false
end

group :system_tests do
  gem "beaker",         :require => false
  gem "beaker-pe",      :require => false
  gem "beaker-rspec",   :require => false
  gem "beaker-vagrant", :require => false
  gem "beaker-puppet_install_helper", :require => false
end

if puppetversion = ENV["PUPPET_GEM_VERSION"]
  gem "puppet", puppetversion, :require => false
else
  gem "puppet", :require => false
end
