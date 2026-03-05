#!/usr/bin/env ruby
require 'yaml'

certname = ARGV[0]
node_name, customer_id = certname.split('.', 2)
customer_id ||= 'e2etesting'

puts YAML.dump({
  'parameters' => {
    'customer'        => customer_id,
    'obmondo'         => {
      'customer_id'  => customer_id,
      'node_name'    => node_name,
      'tags'         => [],
      'monitor'      => false,
      'subscription' => nil,
    },
    'subscription'    => nil,
    'obmondo_monitor' => false,
    'hiera_datapath'  => 'e2e',
    'obmondo_tags'    => [],
  }
})
