# frozen_string_literal: true

require "json"
require "net/http"
require "openssl"

SSL = true
PORT = nil

API_BASE_URL = ENV['OBMONDO_ENV'] == 'beta' ? 'api-beta.obmondo.com' : 'api.obmondo.com'

class HTTPNotFound < ArgumentError
end

def obmondo_api(endpoint, method = "GET", use_basic_auth = true)
  raise NameError, "invalid endpoint '#{endpoint}'" unless endpoint.is_a? String
  raise ArgumentError, "invalid method '#{method}'" unless %w[GET PUT].include?(method.upcase)

  proto = "http#{"s" if SSL}"
  port = (":#{PORT}" if PORT)
  uri = URI("#{proto}://#{API_BASE_URL}#{port}/api#{endpoint}")

  # Direct paths for the certificate and private key
  cert_path = "/etc/puppetlabs/puppet/ssl/certs/puppet.pem"
  key_path = "/etc/puppetlabs/puppet/ssl/private_keys/puppet.pem"

  # Load the certificate and private key from the specified files
  cert = OpenSSL::X509::Certificate.new(File.read(cert_path))
  key = OpenSSL::PKey::RSA.new(File.read(key_path))

  begin
    Net::HTTP.start(uri.host, uri.port, use_ssl: SSL, cert: cert, key: key) do |http|
      request = case method.upcase
      when "GET"
        Net::HTTP::Get.new(uri)
      when "PUT"
        Net::HTTP::Put.new(uri)
      else
        raise ArgumentError, "Unsupported HTTP method: #{method}"
      end

      if use_basic_auth
        request["Authorization"] = "Basic cmVhZG9ubHk6cmVhZG9ubHk=" # Base64-encoded username:password
      end

      response = http.request(request)

      case response.code.to_i
      when 200
        return JSON.parse(response.body)
      when 204
        break
      when 404
        raise HTTPNotFound, response
      else
        raise ArgumentError, "request failed: #{response}"
      end
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
  raise ArgumentError, "invalid certname" unless match

  match
end
