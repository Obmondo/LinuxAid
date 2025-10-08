#!/opt/puppetlabs/puppet/bin/ruby

require_relative "modules/enableit/functions/lib/puppet/functions/api"

# Check for required argument
if ARGV.empty?
  puts "Usage: #{$0} <certname>"
  puts "Example: #{$0} puppetserver.k8sdemo.example.intern"
  exit 1
end

certname = ARGV[0]

ALLOWED_PUPPETDB = [ "puppetdb", "openvoxdb" ]

# Run the special block for matching customer patterns
exit if ALLOWED_PUPPETDB.include?(certname) || obmondo_api("/servers/puppet/certname/#{certname}", "PUT", false).nil?

exit 1
