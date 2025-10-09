source 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? "#{ENV['PUPPET_VERSION']}" : ['>= 4.0']
gem 'puppet', puppetversion
gem 'puppetlabs_spec_helper', '>= 0.8.2'
gem 'puppet-lint', '>= 1.0.0'
gem 'facter', '>= 1.7.0'
gem 'metadata-json-lint'

group :acceptance do
  gem 'beaker-rspec', '5.6.0'
  gem 'serverspec',   require: false
  gem 'specinfra',    require: false
end
