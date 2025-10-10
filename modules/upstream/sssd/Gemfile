source ENV['GEM_SOURCE'] || 'https://rubygems.org'

if (facterversion = ENV['FACTER_GEM_VERSION'])
  gem 'facter', facterversion, :require => false
else
  gem 'facter', :require => false
end

if (puppetversion = ENV['PUPPET_GEM_VERSION'])
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

group :unit_tests do
  gem 'puppet-lint-absolute_classname-check',             :require => false
  gem 'puppet-lint-absolute_template_path',               :require => false
  gem 'puppet-lint-appends-check',                        :require => false
  gem 'puppet-lint-empty_string-check',                   :require => false
  gem 'puppet-lint-file_ensure-check',                    :require => false
  gem 'puppet-lint-leading_zero-check',                   :require => false
  gem 'puppet-lint-spaceship_operator_without_tag-check', :require => false
  gem 'puppet-lint-strict_indent-check',                  :require => false
  gem 'puppet-lint-trailing_comma-check',                 :require => false
  gem 'puppet-lint-trailing_newline-check',               :require => false
  gem 'puppet-lint-undef_in_function-check',              :require => false
  gem 'puppet-lint-unquoted_string-check',                :require => false
  gem 'puppet-lint-variable_contains_upcase',             :require => false
  gem 'puppet-lint-version_comparison-check',             :require => false
  gem 'puppetlabs_spec_helper',                           :require => false
  gem 'rspec-puppet-facts',                               :require => false
end

group :development do
  gem 'simplecov', :require => false
  # gem 'guard-rake',       :require => false
  gem 'librarian-puppet', :require => false
end

group :system_tests do
  gem 'beaker', '~> 4.x',             :require => false
  gem 'beaker-rspec',                 :require => false
  gem 'beaker-puppet',                :require => false
  gem 'beaker-docker',                :require => false
  gem 'serverspec',                   :require => false
  gem 'beaker-puppet_install_helper', :require => false
  gem 'beaker-module_install_helper', :require => false
end

if puppetversion && puppetversion < '5.0'
  gem 'semantic_puppet', :require => false
end

gem 'metadata-json-lint',     :require => false
gem 'public_suffix', '1.4.6', :require => false
gem 'puppet-strings',         :require => false
gem 'redcarpet',              :require => false

# vim:ft=ruby
