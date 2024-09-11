# frozen_string_literal: true

require 'ipaddr'

Puppet::Functions.create_function(:'haproxy::validate_ip_addr') do
  dispatch :validate_ip_addr do
    param 'String', :virtual_ip
    return_type 'Boolean'
  end

  def validate_ip_addr(virtual_ip)
    IPAddr.new(virtual_ip)
    true
  rescue StandardError
    false
  end
end
