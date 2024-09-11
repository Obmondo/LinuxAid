require 'serverspec'
require 'rspec_junit_formatter'

set :backend, :exec

RSpec.configure do |c|
  if ENV['ASK_SUDO_PASSWORD']
    require 'highline/import'
    c.sudo_password = ask('Enter sudo password: ') { |q| q.echo = false }
  else
    c.sudo_password = ENV['SUDO_PASSWORD']
  end

  c.output_stream = File.open('serverspec-result.xml', 'w')
  c.formatter = 'RspecJunitFormatter'
end