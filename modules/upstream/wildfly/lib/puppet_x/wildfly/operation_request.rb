require 'base64'
require 'puppet_x/wildfly/api_client'
require 'puppet_x/wildfly/cli_command'
require 'puppet_x/wildfly/operation_builder'

module PuppetX
  module Wildfly
    class OperationRequest
      def initialize(api_client)
        @api_client = api_client
      end

      # cli

      def exec(command, ignore_failed_outcome = false)
        detyped_request = CLICommand.new(command).to_detyped_request
        @api_client.submit(detyped_request, ignore_failed_outcome)
      end

      def evaluate(command)
        condition, command = command.split(/\sof\s/)
        variable, operator, value = condition.gsub(/[()]/, '').split("\s")

        response = exec(command, :ignore_failed_outcome => true)

        return response[variable].nil? if value == 'undefined'

        condition = if operator == 'has'
                      "#{response[variable].inspect}.include?(#{value})"
                    else
                      "'#{response[variable]}' #{operator} '#{value}'"
                    end

        eval(condition)
      end

      # resource

      def exists?(resource)
        response = @api_client.submit(operation.read(resource).build, :ignore_failed_outcome => true)
        response['outcome'] == 'success'
      end

      def read(resource, recursive = false)
        response = @api_client.submit(operation.read(resource).with(:recursive => recursive).build)
        response['result']
      end

      def add(resource, state, recursive, headers)
        if recursive
          resources = split(resource, state)
          operations = resources.map { |(atomic_resource, atomic_state)| operation.add(atomic_resource).with(atomic_state).build }
          @api_client.submit(operation.composite(*operations).headers(headers).build)
        else
          @api_client.submit(operation.add(resource).with(state).headers(headers).build)
        end
      end

      def update(resource, state, recursive, headers)
        if recursive
          resources = split(resource, state)
          operations = resources.map { |(atomic_resource, atomic_state)| diff(atomic_state, atomic_resource) }.flatten
          @api_client.submit(operation.composite(*operations).headers(headers).build)
        else
          @api_client.submit(operation.composite(*diff(state, resource)).headers(headers).build)
        end
      end

      def split(resource, state)
        child_hashes = state.reject { |_, v| !v.is_a?(Hash) }
        child_resources = child_hashes.reduce([]) { |resources, (k, v)| resources.concat(v.reduce([]) { |r2, (k2, v2)| r2.concat(split("#{resource}/#{k}=#{k2}", v2)) }) }
        base_state = [resource, state.reject { |_, v| v.is_a?(Hash) }]
        [base_state].concat(child_resources)
      end

      def diff(desired_state, resource)
        current_state = read(resource)
        to_update = desired_state.reject { |key, value| value == current_state[key] }
        to_update.map { |attribute, value| operation.write_attribute(resource, attribute, value).build }
      end

      def remove(resource, headers)
        @api_client.submit(operation.remove(resource).headers(headers).build)
      end

      # deployment

      def deployment_checksum(name)
        response = read("/deployment=#{name}")
        bytes_value = response['content'].first['hash']['BYTES_VALUE']
        decoded = Base64.decode64(bytes_value)

        decoded.unpack('H*').first
      end

      def deploy(name, source, server_group, headers)
        @api_client.submit(operation.composite(*deploy_operations(name, source, server_group)).headers(headers).build)
      end

      def deploy_operations(name, source, server_group)
        [operation.add_content(name, source).build, operation.target(server_group).deploy(name).build]
      end

      def undeploy(name, server_group, headers)
        @api_client.submit(operation.composite(*undeploy_operations(name, server_group)).headers(headers).build)
      end

      def undeploy_operations(name, server_group)
        [operation.target(server_group).undeploy(name).build, operation.remove_content(name).build]
      end

      def update_deploy(name, source, server_group, headers)
        @api_client.submit(operation.composite(*update_deploy_operations(name, source, server_group)).headers(headers).build)
      end

      def update_deploy_operations(name, source, server_group)
        undeploy_operations(name, server_group).push(*deploy_operations(name, source, server_group))
      end

      def operation
        OperationBuilder.new
      end
    end
  end
end
