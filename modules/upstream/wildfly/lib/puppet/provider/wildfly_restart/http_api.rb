require File.expand_path(File.join(File.dirname(__FILE__), '..', 'wildfly'))

Puppet::Type.type(:wildfly_restart).provide :http_api, :parent => Puppet::Provider::Wildfly do
  desc 'Uses JBoss HTTP API to manage restarts.'

  def restart
    command = resource[:reload] ? ':reload' : ':shutdown(restart=true)'

    debug "Executing: #{command}"

    cli.exec(command)

    retried = 0

    begin
      pending?
    rescue => e
      raise e unless retried + 1 < @resource[:retries]
      retried += 1
      sleep @resource[:wait]
      retry
    end

    debug 'Done! Server ready.'
  end

  def pending?
    response = cli.exec(':read-attribute(name=server-state)')
    server_state = response['result']

    debug "Server state: #{server_state}"

    state = resource[:reload] ? 'reload' : 'restart'

    server_state == "#{state}-required"
  end
end
