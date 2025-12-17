#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

require 'yaml'

CERTNAME = ARGV[0]
MAX_TAGS = 10
DEFAULT_HIERA_BRANCH = 'enc'
OBMONDO_MONITOR = true
SUBSCRIPTION = false
HIERA_DATADIR = '../../hiera-data'
TAGS_FILE = HIERA_DATADIR + '/' + DEFAULT_HIERA_BRANCH + '/tags.yaml'

# TODO: add support for regex in array list
def find_keys_for_host(data, certname)
  data.select { |key, hosts| hosts.include?(certname) }.keys
end

begin
  LIST_OF_TAGS = YAML.load_file(TAGS_FILE)
  TAG_KEYS = find_keys_for_host(LIST_OF_TAGS, CERTNAME)
rescue
  TAG_KEYS = []
end

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
