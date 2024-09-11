require 'puppet'
require 'yaml'

begin
  require 'riemann/client'
rescue LoadError => ex
  Puppet.info "You need the `riemann-client` gem to use the Riemann report: #{ex}"
end

CONFIGFILE = File.join([Puppet.settings[:confdir], 'riemann.yaml'])
raise(Puppet::ParseError, "Riemann report config file #{configfile} not readable") unless File.exist?(CONFIGFILE)

CONFIG = YAML.load_file(CONFIGFILE)

RIEMANN_SERVER = CONFIG['server'] ||= 'localhost'
RIEMANN_PORT = CONFIG['port'] ||= 5555
RIEMANN_PROTOCOL = CONFIG['protocol'] ||= 'tcp'
RIEMANN_TIMEOUT = CONFIG['timeout'] ||= 60
PUPPET_FAIL_STATE = CONFIG['fail_state'] ||= 'critical'

Puppet::Reports.register_report(:riemann) do
  desc <<-DESC
  Send metrics to Riemann.
  DESC

  def process
    Puppet.debug "Sending metrics for #{host} to Riemann server at #{RIEMANN_SERVER}"
    @r = Riemann::Client.new(
      host: RIEMANN_SERVER,
      port: RIEMANN_PORT,
    )

    @client = @r.method RIEMANN_PROTOCOL

    state = if status == 'failed'
              PUPPET_FAIL_STATE
            else
              'ok'
            end

    @client.call << {
      host: host,
      service: 'puppet',
      state: state,
      description: "Puppet run for #{host} #{status} at #{Time.now.asctime}",
      tags: ['puppet', 'status'],
      timeout: RIEMANN_TIMEOUT,
    }

    metrics.each { |metric, data|
      data.values.each { |(key, value)|
        name = "Puppet #{key} #{metric}"

        @client.call << {
          host: host,
          service: name,
          metric: value,
          tags: ['puppet', 'metric'],
          timeout: RIEMANN_TIMEOUT,
        }
      }
    }
  end
end
