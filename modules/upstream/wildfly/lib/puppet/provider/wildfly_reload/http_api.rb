require 'puppet_x/util/wildfly_cli'

Puppet::Type.type(:wildfly_reload).provide(:http_api) do
  desc 'Uses JBoss HTTP API to manage reloads.'

  def cli
    PuppetX::Util::WildflyCli.new(@resource[:host], @resource[:port], @resource[:username], @resource[:password])
  end

  def reload
    debug "Reloading..."

    cli.exec("reload")

    retried = 0

    begin
      is_pending?
    rescue => e
      if retried + 1 < @resource[:retries]
        retried += 1
        sleep @resource[:wait]
        retry
      else
        raise e
      end
    end

    debug "Reloaded!"
  end

  def is_pending?
    response = cli.exec(":read-attribute(name=server-state)")
    server_state = response['result']

    debug "Server state: #{server_state}"

    server_state == 'reload-required'
  end

end
