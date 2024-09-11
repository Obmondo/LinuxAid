source ENV['GEM_SOURCE'] || 'https://rubygems.org'

group :unit_tests do
  gem 'rubocop', '~> 0.41.2',                                      :require => false if RUBY_VERSION =~ /^1\.9/
  gem 'rubocop',                                                   :require => false if RUBY_VERSION =~ /^2\./
  gem 'puppetlabs_spec_helper',                                    :require => false
  gem 'rspec-puppet-facts',                                        :require => false
  gem 'metadata-json-lint',                                        :require => false
  gem 'json',                                                      :require => false
  gem 'puppet-lint-absolute_classname-check',                      :require => false
  gem 'puppet-lint-absolute_template_path',                        :require => false
  gem 'puppet-lint-alias-check',                                   :require => false
  gem 'puppet-lint-appends-check',                                 :require => false
  gem 'puppet-lint-classes_and_types_beginning_with_digits-check', :require => false
  gem 'puppet-lint-empty_string-check',                            :require => false
  gem 'puppet-lint-file_ensure-check',                             :require => false
  gem 'puppet-lint-file_source_rights-check',                      :require => false
  gem 'puppet-lint-leading_zero-check',                            :require => false
  gem 'puppet-lint-numericvariable',                               :require => false
  gem 'puppet-lint-resource_outside_class-check',                  :require => false
  gem 'puppet-lint-resource_reference_syntax',                     :require => false
  gem 'puppet-lint-spaceship_operator_without_tag-check',          :require => false
  gem 'puppet-lint-strict_indent-check',                           :require => false
  gem 'puppet-lint-trailing_comma-check',                          :require => false
  gem 'puppet-lint-trailing_newline-check',                        :require => false
  gem 'puppet-lint-undef_in_function-check',                       :require => false
  gem 'puppet-lint-unquoted_string-check',                         :require => false
  gem 'puppet-lint-usascii_format-check',                          :require => false
  gem 'puppet-lint-variable_contains_upcase',                      :require => false
  gem 'puppet-lint-version_comparison-check',                      :require => false
end

group :development do
  gem 'simplecov', :require => false
end

group :system_tests do
  gem 'beaker-rspec', :require => false
  gem 'serverspec',   :require => false
end

# json_pure 2.0.2 added a requirement on ruby >= 2. We pin to json_pure 2.0.1
# if using ruby 1.x
gem 'json_pure', '<= 2.0.1', :require => false if RUBY_VERSION =~ /^1\./

if (facterversion = ENV['FACTER_GEM_VERSION'])
  gem 'facter', facterversion, :require => false
else
  gem 'facter', :require => false
end

if (puppetversion = ENV['PUPPET_GEM_VERSION'])
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', '~> 3.8', :require => false
end

# vim:ft=ruby
