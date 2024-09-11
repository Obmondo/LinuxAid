source "http://rubygems.org"

if ENV.key?('PUPPET_VERSION')
  puppetversion = "= #{ENV['PUPPET_VERSION']}"
else
  puppetversion = ['~> 3.1']
end

gem "rake"
gem "puppet", puppetversion
gem "puppet-lint", "1.1.0"
gem "rspec-puppet", "2.0.0"
gem "puppetlabs_spec_helper", "0.8.2"
gem "puppet-syntax", "1.4.1"

if RUBY_VERSION >= '1.9'
  gem 'test-kitchen'
  gem 'librarian-puppet'
  gem 'kitchen-puppet'
  gem 'kitchen-vagrant'
end
