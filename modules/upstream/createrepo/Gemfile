source 'https://rubygems.org'

group :development, :test do
  gem 'rake',                               :require => false
  gem "rspec-puppet",                       :require => false
  gem 'puppetlabs_spec_helper', '< 2.1.1',  :require => false
  gem 'puppet-lint',                        :require => false
  if RUBY_VERSION =~ /^1\./
    gem 'metadata-json-lint', '< 1.2',      :require => false
  else
    gem 'metadata-json-lint',               :require => false
  end
  gem 'puppet-blacksmith',                  :require => false
end

group :system_tests do
  gem 'beaker', '< 4.0',         :require => false
  gem 'beaker-rspec',            :require => false
  gem 'serverspec',              :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end
