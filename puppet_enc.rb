#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

require 'rubygems'

require 'json'
require 'open3'
require 'yaml'

require_relative './modules/enableit/functions/lib/puppet/functions/api.rb'
require_relative './modules/enableit/functions/lib/facter/customer_utils.rb'

BASEDIR = File.expand_path File.dirname(__FILE__)

# If we run the Puppetlabs Docker Puppetserver image (puppetlabs/puppetserver),
# `DUMB_INIT_VERSION` will be set inside the container, and we can use this to
# determine if we're running on our test platform.
TESTING = !ENV['TESTING'].nil?
CERTNAME = if TESTING && CERTNAME == 'puppetdb'
             'puppetdb.4testing'
           else
             ARGV[0]
           end
MAX_TAGS = 10

(hostname, customer_id) = CERTNAME.split('.', 2)
customer_host_re = /^[a-z0-9-]+$/
customer_customerid_re = /^[a-z0-9]{6,10}/

raise ArgumentError, "invalid hostname '#{hostname} used in ENC!" if customer_id.match(customer_customerid_re).nil? && hostname.match(customer_host_re).nil?

certname_parts = split_certname(CERTNAME)
raise ArgumentError, "Certname is wrong: '#{CERTNAME}" if certname_parts.nil?

customer_id = certname_parts['customer_id']
node_name = certname_parts['node_name']

# When running tests we let everyone have a subscription
subscription = if TESTING
                 {'product_id' => 'silver'}
               else
                 begin
                   obmondo_api("/subscription/#{CERTNAME}")
                 rescue
                   nil
                 end
               end

tag_keys = if TESTING
             ['tag1']
           else
             begin
               obmondo_api("/server/#{CERTNAME}/tags")
             rescue ArgumentError => e
               warn 'API is down; no tags available!'
               warn "#{e.class}: #{e}"
               []
             end
           end

# ensure that we don't have too many tags -- if we allow for more tags, we also
# need to update hiera.yaml!
if tag_keys.count > MAX_TAGS
  raise ArgumentError, "Too many tags in use (#{tag_keys.count} of #{MAX_TAGS})"
end

# set all remaining tags to the value `null` to avoid warnings from Hiera.
tag_keys = (tag_keys + Array.new(MAX_TAGS, nil)).slice(0...MAX_TAGS)

# There seems to be no way to have hiera take and expand an array in the
# hierarchy in hiera.yaml, so to circumvent that restriction we instead expand
# all tags and add a line for each tag into hiera.yaml. This means that
# hiera.yaml needs to be updated if we allow more tags. It also has the side
# effect that the ordering of tags matter, so take care when reordering tags!
tags = tag_keys.reduce({}) do |acc, tag|
  acc["obmondo_tag_#{acc.count}"] = tag
  acc
end

parameters = {
  'customer' => customer_id,
  'obmondo' => {
    'customer_id'  => customer_id,
    'node_name'    => node_name,
    'tags'         => tag_keys,
    'monitor'      => !subscription.nil?,
    'subscription' => (subscription['product_id'] unless subscription.nil?),
  },
  'subscription'    => (subscription['product_id'] unless subscription.nil?),
  'obmondo_monitor' => !subscription.nil?,
  'obmondo_tags'    => tag_keys,
}.merge(tags)

output = {
  'parameters' => parameters
}

puts YAML.dump(output)
