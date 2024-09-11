source "https://rubygems.org"

puppetversion = ENV['PUPPET_VERSION'].nil? ? '~> 4.10' : ENV['PUPPET_VERSION'].to_s
puppetver = Gem::Version.new(%r/([\d.]+)/.match(puppetversion)[1])

group :test do
  gem "rake"
  gem "puppet", puppetversion
  gem "rspec", '~> 3.8.0'
  gem "rspec-puppet", :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem "puppetlabs_spec_helper", '~> 2.1'
  gem "metadata-json-lint"
  gem "rspec-puppet-facts"
  gem 'rubocop', '0.57.2'
  gem 'semantic_puppet' unless puppetver >= Gem::Version.new('5.0')
  gem 'simplecov', '>= 0.11.0'
  gem 'simplecov-console'
  gem 'puppet-lint', '>= 2.0.0'
  gem 'puppet-syntax', '~> 2.4.0'
  gem 'json_pure', '<= 2.0.1' if RUBY_VERSION < '2.0.0'
  gem 'net-telnet', '0.1.1'
end

group :development do
  gem "travis"              if RUBY_VERSION >= '2.1.0'
  gem "travis-lint"         if RUBY_VERSION >= '2.1.0'
  gem "guard-rake"          if RUBY_VERSION >= '2.2.5' # per dependency https://rubygems.org/gems/ruby_dep
  gem "puppet-blacksmith"
end

group :system_tests do
  gem 'beaker'       if RUBY_VERSION >= '2.1.8'
  gem 'beaker-rspec' if RUBY_VERSION >= '2.1.8'
end
