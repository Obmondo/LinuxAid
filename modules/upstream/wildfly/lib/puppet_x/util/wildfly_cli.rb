require 'uri'
require 'net/http'
require 'cgi'
require 'json'
require 'puppet_x/util/wildfly_cli_assembler'
require 'puppet_x/util/digest_auth'

module PuppetX
  module Util
    class WildflyCli
      include WildflyCliAssembler

      def initialize(address, port, user, password, timeout = 60)
        @username = user
        @password = password

        @uri = URI.parse "http://#{address}:#{port}/management"
        @uri.user = CGI.escape(user)
        @uri.password = CGI.escape(password)

        @http_client = Net::HTTP.new @uri.host, @uri.port, nil
        @http_client.read_timeout = timeout
      end

      def add_recursive(resource, state)
        body = {
          :address => [],
          :operation => :composite
        }

        all_resources = split_resources(resource, state)

        steps = all_resources.map { |(name, state)| add_body(name, state) }

        body_with_steps = body.merge(:steps => steps)

        send(body_with_steps)
      end

      def add(resource, state)
        body_with_state = add_body(resource, state)

        send(body_with_state)
      end

      def remove(resource)
        body = {
          :address => assemble_address(resource),
          :operation => :remove
        }

        send(body)
      end

      def exists?(resource)
        body = {
          :address => assemble_address(resource),
          :operation => 'read-resource'
        }

        response = send(body, :ignore_outcome => true)
        response['outcome'] == 'success'
      end

      def read(resource, recursive = false)
        body = {
          :address => assemble_address(resource),
          :operation => 'read-resource',
          :recursive => recursive
        }

        response = send(body, :ignore_outcome => true)
        response['outcome'] == 'success' ? response['result'] : {}
      end

      def update_recursive(resource, state)
        all_resources = split_resources(resource, state)

        steps = all_resources.flat_map { |(name, state)| attrs_to_update(name, state).map { |(k, v)| write_attr_body(name, k, v) } }

        composite = {
          :address => [],
          :operation => :composite,
          :steps => steps
        }

        send(composite)
      end

      def update(resource, state)
        updates = attrs_to_update(resource, state).map { |(k, v)| write_attr_body(resource, k, v) }
        composite = {
          :address => [],
          :operation => :composite,
          :steps => updates
        }

        send(composite)
      end

      def exec(command)
        body = assemble_command(command)
        send(body)
      end

      def deploy(name, source, server_group)
        composite = {
          :address => [],
          :operation => :composite,
          :steps => [add_content(name, source), deploy_operation(name, server_group)]
        }

        unless server_group.nil?
          add = {
            :address => [{ 'server-group' => server_group }, { :deployment => name }],
            :operation => :add
          }
          composite[:steps].insert(1, add)
        end

        send(composite)
      end

      def undeploy(name, server_group)
        composite = {
          :address => [],
          :operation => :composite,
          :steps => [undeploy_operation(name, server_group), remove_content(name)]
        }

        unless server_group.nil?
          remove = {
            :address => [{ 'server-group' => server_group }, { :deployment => name }],
            :operation => :remove
          }
          composite[:steps].insert(1, remove)
        end

        send(composite)
      end

      def update_deploy(name, source, server_group)
        composite = {
          :address => [],
          :operation => :composite,
          :steps => [undeploy_operation(name, server_group), remove_content(name), add_content(name, source), deploy_operation(name, server_group)]
        }

        unless server_group.nil?
          remove = {
            :address => [{ 'server-group' => server_group }, { :deployment => name }],
            :operation => :remove
          }
          composite[:steps].insert(1, remove)

          add = {
            :address => [{ 'server-group' => server_group }, { :deployment => name }],
            :operation => :add
          }
          composite[:steps].insert(4, add)

        end

        send(composite)
      end

      private

      def split_resources(name, state)
        # Ruby 1.8.7 Hash doesn't have filter
        child_hashes = state.reject { |k, v| !v.is_a?(Hash) }
        child_resources = child_hashes.reduce([]) { |resources, (k, v)| resources.concat(v.reduce([]) { |r2, (k2, v2)| r2.concat(split_resources("#{name}/#{k}=#{k2}", v2)) }) }
        base_state = [name, state.reject { |k, v| v.is_a?(Hash) }]
        [base_state].concat(child_resources)
      end

      def attrs_to_update(resource, state)
        current_state = read(resource)
        state.select { |k, v| current_state[k] != v }
      end

      def add_body(resource, state)
        body = {
          :address => assemble_address(resource),
          :operation => :add
        }

        body.merge(state)
      end

      def write_attr_body(resource, name, value)
        {
          :address => assemble_address(resource),
          :operation => 'write-attribute',
          :name => name,
          :value => value
        }
      end

      def add_content(name, source)
        {
          :address => { :deployment => name },
          :operation => :add,
          :content => [:url => source]
        }
      end

      def remove_content(name)
        {
          :address => { :deployment => name },
          :operation => :remove
        }
      end

      def deploy_operation(name, server_group)
        deploy = {
          :address => { :deployment => name },
          :operation => :deploy
        }

        unless server_group.nil?
          deploy[:address] = [{ 'server-group' => server_group }, deploy[:address]]
        end

        deploy
      end

      def undeploy_operation(name, server_group)
        undeploy = {
          :address => { :deployment => name },
          :operation => :undeploy
        }

        unless server_group.nil?
          undeploy[:address] = [{ 'server-group' => server_group }, undeploy[:address]]
        end

        undeploy
      end

      def authz_header
        digest_auth = Net::HTTP::DigestAuth.new
        authz_request = Net::HTTP::Get.new @uri.request_uri
        response = @http_client.request authz_request
        if response['www-authenticate'] =~ /digest/i
          digest_auth.auth_header @uri, response['www-authenticate'], 'POST'
        else
          response['www-authenticate']
        end
      end

      def send(body, ignore_outcome = false)
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

        unless response['outcome'] == 'success' || ignore_outcome
          fail "Failed with: #{response['failure-description']} for #{body.to_json}"
        end

        response
      end
    end
  end
end
