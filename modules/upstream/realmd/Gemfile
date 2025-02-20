source 'https://rubygems.org'

puppetversion = ENV['PUPPET_GEM_VERSION'] || '>= 6.18'

group :test do
  gem 'rake'
  gem 'puppet', puppetversion
  gem 'rspec', '~> 3.8.0'
  gem 'rspec-puppet', :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem 'puppetlabs_spec_helper', '~> 2.1'
  gem 'metadata-json-lint'
  gem 'rspec-puppet-facts'
  gem 'rubocop', '0.57.2'
  gem 'simplecov', '>= 0.11.0'
  gem 'simplecov-console'
  gem 'puppet-lint', '>= 2.0.0'
  gem 'puppet-syntax', '~> 2.4.0'
  gem 'json_pure', '<= 2.0.1'
  gem 'net-telnet', '0.1.1'
end

group :development do
  gem 'travis'
  gem 'travis-lint'
  gem 'guard-rake'
  gem 'puppet-blacksmith'
end

group :system_tests do
  gem 'beaker'
  gem 'beaker-vagrant'
  gem 'beaker-rspec'
  gem 'beaker-puppet'
end
