require File.expand_path(File.join(File.dirname(__FILE__), '..', 'wildfly'))

Puppet::Type.type(:wildfly_deployment).provide :http_api, :parent => Puppet::Provider::Wildfly do
  desc 'Uses JBoss HTTP API to perfom deploy'

  def create
    debug "Deploying #{@resource[:name]} from source #{@resource[:source]}"
    cli.deploy(@resource[:name], @resource[:source], @resource[:server_group], @resource[:operation_headers])
  end

  def destroy
    debug "Undeploying #{@resource[:name]}"
    cli.undeploy(@resource[:name], @resource[:server_group], @resource[:operation_headers])
  end

  def exists?
    debug "Exists? #{@resource[:name]}"
    cli.exists?("#{server_group_address}/deployment=#{@resource[:name]}")
  end

  def content
    cli.deployment_checksum(@resource[:name])
  end

  def content=(value)
    debug "Updating deploy #{@resource[:name]} with content from #{@resource[:source]}"
    cli.update_deploy(@resource[:name], @resource[:source], @resource[:server_group], @resource[:operation_headers])
  end

  def server_group_address
    "/server-group=#{@resource[:server_group]}" unless @resource[:server_group].nil?
  end
end
