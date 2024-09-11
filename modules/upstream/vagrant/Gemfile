source 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? ENV['PUPPET_VERSION'] : '3.7.2'

group :rspec, :kitchen do
  gem 'librarian-puppet', '2.1.1'
  gem 'puppet', puppetversion
  gem 'rspec_junit_formatter'
  gem 'puppet-blacksmith'
end

group :rspec do
  gem 'puppetlabs_spec_helper', '>= 0.1.0'
  gem 'puppet-lint', '< 1.1.0'
  gem 'puppet-lint-unquoted_string-check'
  gem 'facter', '>= 1.7.0'
  gem 'rspec-puppet', :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem 'puppet-syntax'
  gem 'metadata-json-lint'
end

group :kitchen do
  #gem 'puppet_forge', '<= 1.0.2'
  gem 'test-kitchen'
  gem 'kitchen-puppet'
  gem 'kitchen-docker'
  gem 'kitchen-vagrant'
  gem 'vagrant-wrapper'
end
