require File.expand_path(File.join(File.dirname(__FILE__), '..', 'wildfly'))

Puppet::Type.type(:wildfly_resource).provide :http_api, :parent => Puppet::Provider::Wildfly do
  desc 'Uses JBoss HTTP API to manipulate a resource'

  def create
    debug "Creating #{@resource[:path]} with state #{@resource[:state].inspect}"
    cli.add(@resource[:path], @resource[:state], @resource[:recursive], @resource[:operation_headers])
  end

  def destroy
    debug "Destroying #{@resource[:path]}"
    cli.remove(@resource[:path], @resource[:operation_headers])
  end

  def exists?
    debug "Exists? #{@resource[:path]}"
    cli.exists?(@resource[:path])
  end

  def state
    debug "Retrieve state: #{@resource[:path]}"
    cli.read(@resource[:path], @resource[:recursive])
  end

  def state=(value)
    debug "Updating state for: #{@resource[:path]} with #{@resource[:state].inspect}"
    cli.update(@resource[:path], value, @resource[:recursive], @resource[:operation_headers])
  end
end
