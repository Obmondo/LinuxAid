# frozen_string_literal: true

require 'json'
require 'net/http'

SSL = true
PORT = nil

class HTTPNotFound < ArgumentError
end

def obmondo_api(endpoint)
  raise NameError, "invalid endpoint '#{endpoint}'" unless
    endpoint.is_a? String

  proto = "http#{'s' if SSL}"
  port = if PORT
           ":#{PORT}"
         end
  uri = URI("#{proto}://api.obmondo.com#{port}/api#{endpoint}")

  begin
    Net::HTTP.start(uri.host, uri.port, use_ssl: SSL) do |http|
      response = http.get(uri.path,
                          'Authorization' => 'Basic cmVhZG9ubHk6cmVhZG9ubHk=')

      raise HTTPNotFound, response if response.code.to_i == 404
      return JSON.parse(response.body) if response.code.to_i == 200

      raise ArgumentError, "request failed: #{response}"
    end
  rescue SocketError => e
    raise "API: unable to contact obmondo API #{e}"
  rescue Timeout::Error => e
    raise "API: Failed with timeout error #{e}"
  end
end

def split_certname(certname)
  match = certname
          .match(/^(?<node_name>[a-z0-9-]+)\.(?<customer_id>[a-z0-9-]+$)/)
  raise ArgumentError, 'invalid certname' unless match

  match
end
