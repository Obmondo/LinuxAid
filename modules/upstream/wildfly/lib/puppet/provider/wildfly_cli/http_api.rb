require File.expand_path(File.join(File.dirname(__FILE__), '..', 'wildfly'))

Puppet::Type.type(:wildfly_cli).provide :http_api, :parent => Puppet::Provider::Wildfly do
  desc 'Uses JBoss HTTP API to execute a JBoss-CLI command'

  def exec(command)
    debug "Running: #{command}"
    cli.exec(command)
  end

  def should_execute?
    unless_eval = true
    onlyif_eval = false

    unless @resource[:unless].nil?
      unless_eval = cli.evaluate(@resource[:unless])
    end

    unless @resource[:onlyif].nil?
      onlyif_eval = cli.evaluate(@resource[:onlyif])
    end

    onlyif_eval || !unless_eval || (@resource[:unless].nil? && @resource[:onlyif].nil?)
  end
end
