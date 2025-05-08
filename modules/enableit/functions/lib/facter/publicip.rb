# Fact for getting our own public IP from EnableIT API

require 'net/http'

SSL = true
PORT = 443

# NOTE: copied from here and tweaked a bit
# https://gitlab.enableit.dk/obmondo/puppet/-/blob/master/modules/enableit/functions/lib/puppet/functions/api.rb
def obmondo_api(endpoint)
  raise NameError, "invalid endpoint '#{endpoint}'" unless
    endpoint.is_a? String

  proto = "http#{'s' if SSL}"
  port = if PORT
           ":#{PORT}"
         end
  uri = URI("#{proto}://api.obmondo.com#{port}/api#{endpoint}")

  begin
    Net::HTTP.start(uri.host, uri.port,
                   use_ssl: SSL,
                   open_timeout: 1, read_timeout: 2) do |http|
      response = http.get(uri.path)

      return response.body if response.code.to_i == 200

      raise ArgumentError, "request failed: #{response}"
    end
  rescue SocketError => e
    raise "API: unable to contact obmondo API #{e}"
  rescue Timeout::Error => e
    raise "API: Failed with timeout error #{e}"
  end
end

Facter.add('publicip') do
  setcode do
    certname = Facter.value(:obmondo)['certname']
    obmondo_api("/server/#{certname}/publicip")
  end
end
