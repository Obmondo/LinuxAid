require 'base64'
require 'puppet_x/util/wildfly_cli'

Puppet::Type.type(:wildfly_deploy).provide(:http_api) do

  desc 'Uses JBoss HTTP API to perfom deploy'

  def cli
    PuppetX::Util::WildflyCli.instance(@resource[:host], @resource[:port], @resource[:username], @resource[:password])
  end

  def create
    debug "Deploying #{@resource[:name]} from source #{@resource[:source]}"
    cli.deploy(@resource[:name], @resource[:source])
  end

  def destroy
    debug "Undeploying #{@resource[:name]}"
    cli.undeploy(@resource[:name])
  end

  def exists?
    debug "Exists? #{@resource[:name]}"
    cli.exists?("/deployment=#{@resource['name']}")
  end

  def content
    response = cli.read("/deployment=#{@resource['name']}")
    bytes_value = response['content'].first['hash']['BYTES_VALUE']
    decoded = Base64.decode64(bytes_value)

    content_sha1_sum = decoded.unpack('H*').first

    debug "Current content SHA1: #{content_sha1_sum}"

    content_sha1_sum
  end

  def content=(value)
    debug "Updating deploy #{@resource[:name]} with content from #{@resource[:source]}"
    cli.update_deploy(@resource[:name], @resource[:source])
  end
end
