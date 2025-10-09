require 'puppet_x/wildfly/cli_command'

module PuppetX
  module Wildfly
    class OperationBuilder
      def initialize
        @detyped_request = {
          :address => []
        }
      end

      def target(name)
        unless name.nil?
          @detyped_request[:address] << { 'server-group' => name }
        end
        self
      end

      def add(name)
        @detyped_request[:operation] = :add
        @detyped_request[:address] = path_to_address(name)
        self
      end

      def read(name)
        @detyped_request[:operation] = 'read-resource'
        @detyped_request[:address] = path_to_address(name)
        self
      end

      def write_attribute(path, attribute, value)
        @detyped_request[:operation] = 'write-attribute'
        @detyped_request[:address] = path_to_address(path)
        @detyped_request[:name] = attribute
        @detyped_request[:value] = value
        self
      end

      def remove(name)
        @detyped_request[:operation] = :remove
        @detyped_request[:address] = path_to_address(name)
        self
      end

      def remove_content(name)
        @detyped_request[:operation] = :remove
        @detyped_request[:address] << { :deployment => name }
        self
      end

      def add_content(name, source)
        @detyped_request[:operation] = :add
        @detyped_request[:content] = [:url => "file:#{source}"]
        @detyped_request[:address] << { :deployment => name }
        self
      end

      def deploy(name)
        operation = @detyped_request[:address].empty? ? :deploy : :add
        @detyped_request[:operation] = operation
        @detyped_request[:address] << { :deployment => name }
        self
      end

      def undeploy(name)
        operation = @detyped_request[:address].empty? ? :undeploy : :remove
        @detyped_request[:operation] = operation
        @detyped_request[:address] << { :deployment => name }
        self
      end

      def composite(*steps)
        @detyped_request[:operation] = :composite
        @detyped_request[:steps] = steps
        self
      end

      def headers(headers)
        @detyped_request['operation-headers'] = headers
        self
      end

      def with(state)
        @detyped_request.merge!(state)
        self
      end

      def path_to_address(path)
        # change grammar to avoid :dummy
        CLICommand.new("#{path}:dummy").address
      end

      def build
        @detyped_request
      end
    end
  end
end
