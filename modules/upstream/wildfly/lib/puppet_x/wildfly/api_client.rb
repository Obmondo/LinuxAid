require 'uri'
require 'net/http'
require 'cgi'
require 'json'
require 'net/http/digest_auth'

module PuppetX
  module Wildfly
    class APIClient
      def initialize(address, port, user, password, timeout)
        @username = user
        @password = password

        @uri = URI.parse "http://#{address}:#{port}/management"
        @uri.user = CGI.escape(user)
        @uri.password = CGI.escape(password)

        @http_client = Net::HTTP.new @uri.host, @uri.port, nil
        @http_client.read_timeout = timeout
      end

      def authz_header
        digest_auth = Net::HTTP::DigestAuth.new
        authz_request = Net::HTTP::Get.new @uri.request_uri

        retried = 0

        # All http_api providers require Wildfly service to be up, but with systemd there is no guarantee that the service is actually running, therefore we need to retry

        begin
          response = @http_client.request authz_request
        rescue => e
          raise e unless retried + 1 < 6
          retried += 1
          sleep 10
          retry
        end

        if response['www-authenticate'] =~ /digest/i
          digest_auth.auth_header @uri, response['www-authenticate'], 'POST'
        else
          response['www-authenticate']
        end
      end

      def submit(body, ignore_failed_outcome = false)
        http_request = Net::HTTP::Post.new @uri.request_uri
        http_request.add_field 'Content-type', 'application/json'
        authz = authz_header
        if authz =~ /digest/i
          http_request.add_field 'Authorization', authz
        else
          http_request.basic_auth @username, @password
        end

        http_request.body = body.to_json
        http_response = @http_client.request http_request
        response = JSON.parse(http_response.body)

        unless response['outcome'] == 'success' || ignore_failed_outcome
          raise "Failed with: #{response['failure-description']} for #{body.to_json}"
        end

        response
      end
    end
  end
end
