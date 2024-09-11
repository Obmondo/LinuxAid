source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :test do
  gem 'rake'
  gem 'puppet', ENV['PUPPET_GEM_VERSION'] || '~> 3.8.0'
  gem 'rspec-core', '< 3.2.0' if RUBY_VERSION < '1.9'
  gem 'rspec-puppet'
  gem 'puppetlabs_spec_helper'
  gem 'metadata-json-lint', '1.1' if RUBY_VERSION < '1.9'
  gem 'rspec-puppet-facts'
  gem 'puppet-blacksmith'

  gem 'puppet-lint-absolute_classname-check'
  gem 'puppet-lint-leading_zero-check'
  gem 'puppet-lint-trailing_comma-check'
  gem 'puppet-lint-version_comparison-check'
  gem 'puppet-lint-classes_and_types_beginning_with_digits-check'
  gem 'puppet-lint-unquoted_string-check'
  gem 'puppet-lint-resource_reference_syntax'
end
