source 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : ['= 3.7.5']

platform :ruby_19, :ruby_20 do
  gem 'coveralls', :require => false
  gem 'simplecov', :require => false
end
gem 'puppet-lint'
gem 'puppet', puppetversion
gem 'rspec', '>= 3.2.0'
gem 'rspec-puppet', '>= 2.1.0'
gem 'rspec-system-puppet'
gem 'puppetlabs_spec_helper'
gem 'puppet-syntax'
gem 'facter', '>= 1.6.10'
# gem 'ci_reporter_rspec'
gem 'rubocop', :git => 'https://github.com/bbatsov/rubocop',  :require => false
gem 'puppet-blacksmith'
gem 'fog', '>= 1.25.0'
gem 'fog-google', '= 0.1.0'
gem 'beaker', '>= 2.0.0'
gem 'beaker-rspec', '>= 5.0.0'
gem 'serverspec', '>= 2.0.0'

