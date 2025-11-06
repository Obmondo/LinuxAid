source 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_GEM_VERSION') ? "#{ENV['PUPPET_GEM_VERSION']}" : ['>= 3.3']
gem 'puppet', puppetversion
gem 'puppetlabs_spec_helper', '>= 0.8.2'
gem 'puppet-lint', '>= 1.0.0'
gem 'facter', '>= 1.7.0'
gem 'mocha'

# JSON must be 1.x on Ruby 1.9
if RUBY_VERSION < '2.0'
  gem "json", ">= 2.3.0"
  gem 'json_pure', '~> 1.0'
end

if RUBY_VERSION < '1.9'
  gem "rake", ">= 12.3.3"

  # https://github.com/rspec/rspec-core/issues/1864
  gem 'rspec', '< 3.2.0'
else
  gem 'rspec'

end
