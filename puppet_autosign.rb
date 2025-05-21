#!/opt/puppetlabs/puppet/bin/ruby
# https://puppet.com/docs/puppet/latest/ssl_autosign.html#policy-based-autosigning

require_relative "modules/enableit/functions/lib/puppet/functions/api"

CERTNAME = ARGV[0]

Kernel.exit(0) if CERTNAME == "puppetdb" || obmondo_api("/servers/puppet/certname/#{CERTNAME}", "PUT", false).nil?

Kernel.exit(1)
