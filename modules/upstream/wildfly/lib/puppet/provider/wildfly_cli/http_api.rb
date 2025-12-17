require File.expand_path(File.join(File.dirname(__FILE__), '..', 'wildfly'))

Puppet::Type.type(:wildfly_cli).provide :http_api, :parent => Puppet::Provider::Wildfly do
  desc 'Uses JBoss HTTP API to execute a JBoss-CLI command'

  def exec_command
    debug "Running: #{@resource[:command]}"
    cli.exec(@resource[:command])
  end

  def should_execute?
    unless_eval = true
    onlyif_eval = false

    skip = @resource[:skip_absent] && !cli.exists?(@resource[:command].split(':')[0])

    unless @resource[:unless].nil?
      unless_eval = cli.evaluate(@resource[:unless])
    end

    unless @resource[:onlyif].nil?
      onlyif_eval = cli.evaluate(@resource[:onlyif])
    end

    !skip && (onlyif_eval || !unless_eval || (@resource[:unless].nil? && @resource[:onlyif].nil?))
  end
end
