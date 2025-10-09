def local_load(*gems)
  gems.each do |gem|
    path = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'puppet_x/wildfly/gems/', gem, '/lib'))
    $LOAD_PATH.unshift(path) unless $LOAD_PATH.include? path
  end
end

local_load('net-http-digest_auth-1.4', 'polyglot-0.3.5', 'treetop-1.6.8')

class Puppet::Provider::Wildfly < Puppet::Provider
  def cli
    require 'puppet_x/wildfly/api_client'
    require 'puppet_x/wildfly/operation_request'
    timeout = @resource.parameters.include?(:timeout) ? resource[:timeout] : 60

    api_client = PuppetX::Wildfly::APIClient.new(@resource[:host], @resource[:port], @resource[:username], @resource[:password], timeout)
    PuppetX::Wildfly::OperationRequest.new(api_client)
  end
end
