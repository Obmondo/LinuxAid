#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

require 'yaml'

CERTNAME = ARGV[0]
MAX_TAGS = 10
DEFAULT_HIERA_BRANCH = 'main'
OBMONDO_MONITOR = true

tag_keys = []

# set all remaining tags to the value `null` to avoid warnings from Hiera.
tag_keys = (tag_keys + Array.new(MAX_TAGS, nil)).slice(0...MAX_TAGS)

parameters = {
  'node_name'       => CERTNAME,
  'obmondo_monitor' => OBMONDO_MONITOR,
  'hiera_datapath'  => DEFAULT_HIERA_BRANCH,
  'obmondo_tags'    => tag_keys,
}

output = {
  'parameters' => parameters
}

puts YAML.dump(output)
