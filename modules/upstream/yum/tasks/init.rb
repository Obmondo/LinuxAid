#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

require 'json'
require 'open3'
require 'puppet'

def yum(action, quiet)
  cmd = ['yum', '-y']
  cmd << '-q' unless quiet == false || quiet.nil?
  cmd += action.split(%r{\s+})

  stdout, stderr, status = Open3.capture3(*cmd)
  raise Puppet::Error, stderr unless status.success?

  { status: stdout.strip }
end

def process_list_updates(output)
  status = output[:status].lines[1..]
  status ||= []

  result = status.map do |line|
    package, available_version, repository = line.split(%r{\s+})
    {
      package: package,
      available_version: available_version,
      repository: repository
    }
  end

  { status: result }
end

params = JSON.parse($stdin.read)
action = params['action']
quiet = params['quiet']

begin
  result = yum(action, quiet)
  result = process_list_updates(result) if action == 'list updates'
  puts result.to_json
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
