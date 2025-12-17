module PuppetX
  module Wildfly
    module DeepHash
      def _deep_intersect(current_state, desired_state)
        diff = {}

        current_state.each do |key, value|
          next unless desired_state.is_a? Hash and desired_state.keys.include? key
          diff[key] = if value.is_a? Hash
                        _deep_intersect(value, desired_state[key])
                      else
                        value
                      end
        end

        diff
      end

      def _deep_transform_values_in_object(object, &block)
        case object
        when Hash
          object.each_with_object({}) do |(key, value), result|
            result[key] = _deep_transform_values_in_object(value, &block)
          end
        when Array
          object.map { |e| _deep_transform_values_in_object(e, &block) }
        else
          yield(object)
        end
      end

      def should
        _deep_transform_values_in_object(super) { |value| value == :undef ? nil : value }
      end

      def insync?(is)
        desired_state = should
        _deep_intersect(is, desired_state) == desired_state
      end

      def change_to_s(current_value, new_value)
        changed_keys = (new_value.to_a - current_value.to_a).collect { |key, _| key }

        current_value = current_value.delete_if { |key, _| !changed_keys.include? key }.inspect
        new_value = new_value.delete_if { |key, _| !changed_keys.include? key }.inspect

        super(current_value, new_value)
      end
    end
  end
end
