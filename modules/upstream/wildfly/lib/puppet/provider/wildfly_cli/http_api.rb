require 'puppet_x/util/wildfly_cli'

Puppet::Type.type(:wildfly_cli).provide(:http_api) do
  desc 'Uses JBoss HTTP API to execute a JBoss-CLI command'

  def cli
    PuppetX::Util::WildflyCli.new(@resource[:host], @resource[:port], @resource[:username], @resource[:password])
  end

  def exec(command)
    debug "Running: #{command}"
    cli.exec(command)
  end

  def should_execute?
    unless_eval = true
    onlyif_eval = false

    unless @resource[:unless].nil?
      unless_eval = evaluate_command(@resource[:unless])
    end

    unless @resource[:onlyif].nil?
      onlyif_eval = evaluate_command(@resource[:onlyif])
    end

    onlyif_eval || !unless_eval
  end

  def evaluate_command(command)
    condition, command = command.split(/\sof\s/)
    variable, operator, value = condition.sub('(', '').sub(')', '').split(/\s/)
    response = cli.exec(command)

    debug "Executing: #{command} to verify: (#{condition})"

    if operator == 'has'
      condition = "#{response[variable].inspect}.include?(#{value})"
    else
      condition = "'#{response[variable]}' #{operator} '#{value}'"
    end

    debug "Condition (#{condition})"

    eval(condition)
  end
end
