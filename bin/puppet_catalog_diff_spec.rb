#!/usr/bin/env ruby
# Script that computes catalog differences for specified hosts.

require 'open3'
require 'shellwords'
require 'tempfile'
require 'rspec'
require 'net/http'
require 'uri'
require 'json'
require 'openssl'

# Get the list of hosts from the api
def fetch_hosts
  uri = URI('https://api.obmondo.com/api/servers')

  Net::HTTP.start(
    uri.host, uri.port,
    :use_ssl => uri.scheme == 'https') do |http|

    request = Net::HTTP::Get.new uri.request_uri
    request.basic_auth 'readonly', 'readonly'

    response = http.request request # Net::HTTPResponse object

    servers = JSON.parse(response.body)

    servers.map do |server|
      server['certname']
    end
  end
end

hosts = fetch_hosts.sample(20)

raise ArgumentError, 'Must pass a HOST_LIST' if hosts.nil? || hosts.empty?

CHECKOUT_DIR = './'

DIFF_ARGV = [
  'octocatalog-diff',
  "--from=origin/#{ENV['CI_COMMIT_BRANCH']}",
  '--to=master',
  '--quiet',
  '--no-header',
  '--ignore', 'Anchor[*]',
  '--ignore', 'Node[*]',
  '--retry-failed-catalog', '1'
].freeze

def run_octocatalog_diff(hostname)
  argv = DIFF_ARGV.dup
  argv.concat ['--hostname', hostname]
  cmd = argv.map { |x| Shellwords.escape(x) }.join(' ')
  Open3.capture2e(cmd, chdir: CHECKOUT_DIR)
end

hosts.each do |hostname|
  puts "### Catalog-Diff #{hostname} ###"
  exit_code, result = run_octocatalog_diff(hostname)
  puts exit_code, result
end
