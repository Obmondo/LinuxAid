#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

require 'yaml'

CERTNAME = ARGV[0]
MAX_TAGS = 10
DEFAULT_HIERA_BRANCH = 'main'
OBMONDO_MONITOR = true
SUBSCRIPTION = false
TAG_KEYS = []

parameters = {
  'node_name'       => CERTNAME,
  'obmondo_monitor' => OBMONDO_MONITOR,
  'hiera_datapath'  => DEFAULT_HIERA_BRANCH,
  'obmondo_tags'    => TAG_KEYS,
  'subscription'    => SUBSCRIPTION,
}

output = {
  'parameters' => parameters
}

puts YAML.dump(output)
