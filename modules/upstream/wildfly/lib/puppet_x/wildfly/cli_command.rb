require 'treetop'
require 'puppet_x/wildfly/jboss_cli'

module PuppetX
  module Wildfly
    class CLICommand
      def initialize(command)
        parser = JBossCLIParser.new
        @syntax_node = parser.parse(command)

        raise "Invalid command syntax. Could not parse: #{command}" if @syntax_node.nil?
      end

      def address
        address_to_key_value_list(@syntax_node.elements[0])
      end

      def operation
        operation = @syntax_node.elements[2]
        operation.empty? ? '' : operation.text_value
      end

      def params
        params_to_key_value_list(@syntax_node.elements[3])
      end

      def headers
        params_to_key_value_list(@syntax_node.elements[4])
      end

      def address_to_key_value_list(node)
        list = []

        unless node.empty?
          nodes = node.elements

          nodes.size.times do |index|
            element = nodes[index]
            list << { element.elements[1].text_value => element.elements[3].text_value.delete('"') }
          end
        end

        list
      end

      def params_to_key_value_list(node)
        list = []

        unless node.empty?
          nodes = node.elements[1].elements

          nodes.size.times do |index|
            element = nodes[index].elements[0]

            list << { element.elements[0].text_value => extract_value(element.elements[2]) }
          end
        end

        list
      end

      def extract_value(element)
        case element.elements[0].text_value
        when '['
          values = []

          values << element.elements[1].text_value

          list = element.elements[2].elements

          list.size.times do |index|
            values << list[index].elements[1].text_value
          end

          values
        when '{'
          values = {}
          key_value = element.elements[1]
          pairs = element.elements[2].elements

          values[key_value.elements[0].text_value] = key_value.elements[2].text_value

          pairs.size.times do |index|
            pair = pairs[index].elements[1]

            values[pair.elements[0].text_value] = pair.elements[2].text_value
          end

          values
        else
          element.text_value
        end
      end

      def to_detyped_request
        request = {}
        request[:operation] = operation
        request[:address] = address

        params.each do |param|
          param.each do |key, value|
            request[key] = value
          end
        end

        unless headers.empty?
          request['operation-headers'] = {}
          headers.each do |header|
            header.each do |key, value|
              request['operation-headers'].store(key, value)
            end
          end
        end

        request
      end
    end
  end
end
