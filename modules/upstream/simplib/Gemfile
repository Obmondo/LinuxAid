# ------------------------------------------------------------------------------
#         NOTICE: **This file is maintained with puppetsync**
#
# This file is automatically updated as part of a puppet module baseline.
# The next baseline sync will overwrite any local changes made to this file.
# ------------------------------------------------------------------------------
gem_sources = ENV.fetch('GEM_SERVERS', 'https://rubygems.org').split(%r{[, ]+})

gem_sources.each { |gem_source| source gem_source }

group :syntax do
  gem 'metadata-json-lint'
  gem 'puppet-lint-trailing_comma-check', require: false
  # rubocop, rubocop-rake, and rubocop-rspec are pulled in and version-pinned by
  # voxpupuli-test (via simp-rake-helpers); pinning them here conflicts with its
  # constraints. rubocop-performance is not a voxpupuli-test dependency, so it
  # stays explicit.
  gem 'rubocop-performance', '~> 1.26.0'
end

group :test do
  puppet_version = ENV.fetch('PUPPET_VERSION', ['>= 8', '< 9'])
  openvox_version = ENV.fetch('OPENVOX_VERSION', puppet_version)
  gem 'hiera-puppet-helper'
  gem 'openvox', openvox_version
  gem 'openvox-strings'
  gem 'rake'
  gem 'rspec'
  gem 'rspec-puppet'
  # renovate: datasource=rubygems versioning=ruby
  gem 'simp-rake-helpers', ENV.fetch('SIMP_RAKE_HELPERS_VERSION', '~> 6.0')
  # renovate: datasource=rubygems versioning=ruby
  gem 'simp-rspec-puppet-facts', ENV.fetch('SIMP_RSPEC_PUPPET_FACTS_VERSION', '~> 4.0.0')
  gem 'syslog', require: false
  # Ruby 3.4+ removed 'observer' from default gems, but 'drb' (pulled in by
  # rspec/beaker dependencies) still requires it.
  gem 'observer', require: false
end

group :development do
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-doc'
end

group :system_tests do
  gem 'bcrypt_pbkdf'
  gem 'beaker'
  gem 'beaker_puppet_helpers'
  gem 'beaker-rspec'
  # renovate: datasource=rubygems versioning=ruby
  gem 'simp-beaker-helpers', ENV.fetch('SIMP_BEAKER_HELPERS_VERSION', '~> 3.1')
end

# Evaluate extra gemfiles if they exist
extra_gemfiles = [
  ENV.fetch('EXTRA_GEMFILE', ''),
  "#{__FILE__}.project",
  "#{__FILE__}.local",
  File.join(Dir.home, '.gemfile'),
]
extra_gemfiles.each do |gemfile|
  if File.file?(gemfile) && File.readable?(gemfile)
    eval(File.read(gemfile), binding) # rubocop:disable Security/Eval
  end
end
