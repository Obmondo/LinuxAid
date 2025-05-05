# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'
require 'puppet'

module PuppetX
  module Gitlab
    module APIClient
      def self.delete(url, options, proxy, ca_file)
        response = request(url, Net::HTTP::Delete, options, proxy, ca_file)
        validate(response)

        {}
      end

      def self.post(url, options, proxy, ca_file)
        response = request(url, Net::HTTP::Post, options, proxy, ca_file)
        validate(response)

        JSON.parse(response.body)
      end

      def self.request(url, http_method, options, proxy, ca_file)
        uri     = URI.parse(url)
        headers = {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }
        if proxy
          proxy_uri = URI.parse(proxy)
          proxy_host = proxy_uri.host
          proxy_port = proxy_uri.port
        else
          proxy_host = nil
          proxy_port = nil
        end

        http = Net::HTTP.new(uri.host, uri.port, proxy_host, proxy_port)
        if uri.scheme == 'https'
          http.use_ssl     = true
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          http.ca_file = ca_file if ca_file
        end
        request          = http_method.new(uri.request_uri, headers)
        request.body     = options.to_json

        begin
          http.request(request)
        rescue Net::OpenTimeout
          msg = if http.proxy?
                  "Timeout connecting to proxy #{http.proxy_address} when trying to register/unregister gitlab runner"
                else
                  "Timeout connecting to #{http.address} when trying to register/unregister gitlab runner"
                end
          raise Puppet::Error, msg
        end
      end

      def self.validate(response)
        raise Net::HTTPError.new(response.message, response) unless response.code.start_with?('2')
      end
    end

    module Runner
      def self.register(host, options, proxy = nil, ca_file = nil)
        url = "#{host}/api/v4/runners"
        Puppet.info "Registering gitlab runner with #{host}"
        PuppetX::Gitlab::APIClient.post(url, options, proxy, ca_file)
      end

      def self.unregister(host, options, proxy = nil, ca_file = nil)
        url = "#{host}/api/v4/runners"
        Puppet.info "Unregistering gitlab runner with #{host}"
        PuppetX::Gitlab::APIClient.delete(url, options, proxy, ca_file)
      end
    end
  end
end
