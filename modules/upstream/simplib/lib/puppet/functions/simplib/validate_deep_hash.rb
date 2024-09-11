# Perform a deep validation on two passed `Hashes`.
#
# * All keys must be defined in the reference `Hash` that is being
#   validated against.
# * Unknown keys in the `Hash` being compared will cause a failure in
#   validation
# * All values in the final leaves of the 'reference 'Hash' must
#   be a String, Boolean, or nil.
# * All values in the final leaves of the `Hash` being compared must
#   support a to_s() method.
# * Terminates catalog compilation if validation fails.
#
Puppet::Functions.create_function(:'simplib::validate_deep_hash') do

  # @param reference Hash to validate against. Keys at all levels of
  #   the hash define the structure of the hash and the value at each
  #   final leaf in the hash tree contains a regular expression string,
  #   a boolean or nil for value validation:
  #
  #   * When the validation value is a regular expression string,
  #     the string representation of the to_check value (from the
  #     to_s() method) will be compared to the regular expression
  #     contained in the reference string.
  #
  #   * When the validation value is a Boolean, the string
  #     representation of the to_check value will be compared
  #     with the string representation of the Boolean (as provided
  #     by the to_s() method).
  #
  #   * When the validation value is a `nil` or 'nil', no value
  #     validation will be done for the key.
  #
  #   * When the to_check value contains an `Array` of values for a
  #     key, the validation for that key will be applied to each
  #     element in that array.
  #
  # @param to_check Hash to be validated against the reference
  # @return [Nil]
  # @raise [RuntimeError] if validation fails
  #
  # @example Passing Examples
  #   reference = {
  #     'foo' => {
  #       'bar' => {
  #         #NOTE: Use quotes for regular expressions instead of '/'
  #         'baz' => '^\d+$',
  #         'abc' => '^\w+$',
  #         'def' => nil
  #       },
  #       'baz' => {
  #         'qrs' => false
  #         'xyz' => '^true|false$'
  #       }
  #     }
  #   }
  #
  #   to_check = {
  #     'foo' => {
  #       'bar' => {
  #         'baz' => ['123', 45]
  #         'abc' => [ 'these', 'are', 'words' ],
  #         'def' => 'Anything will work here!'
  #       },
  #       'baz' => {
  #         'qrs' => false
  #         'xyz' => true
  #       }
  #     }
  #   }
  #
  #   validate_deep_hash(reference, to_check)
  #
  # @example Failing Examples
  #   reference => { 'foo' => '^\d+$' }
  #   to_check  => { 'foo' => 'abc' }
  #
  #   validate_deep_hash(reference, to_check)
  #
  dispatch :validate_deep_hash do
    required_param 'Hash', :reference
    required_param 'Hash', :to_check
  end

  def validate_deep_hash(reference, to_check)
    invalid = deep_validate(reference, to_check)

    if invalid.size > 0 then
      err_msg = "simplib::validate_deep_hash failed validation:\n  "
      err_msg += invalid.join("\n  ")
      fail(err_msg)
    end
  end

  def valid_value(value)
    [String, TrueClass, FalseClass, Numeric, NilClass].each do |allowed_class|
      return true if value.is_a?(allowed_class)
    end
    return false
  end

  def compare(ref_value, to_check_value)
    return :invalid_ref_type unless valid_value(ref_value)

    ref_string = ref_value.to_s

    Array(to_check_value).each do |value|
      return :invalid_check_type unless value.respond_to?(:to_s)
      return :failed_check unless Regexp.new(ref_string).match(value.to_s)
    end
    return :success
  end

  def deep_validate(reference, to_check, level="TOP", invalid = Array.new)
    to_check.each do |key,value|
      if reference.has_key?(key)
        # skip over keys for which further validation has been disabled
        next if reference[key].nil? or reference[key] == 'nil'

        # Step down a level if value is another hash
        if value.is_a?(Hash)
          if reference[key].is_a?(Hash)
            ref_key_hash = reference[key]
            deep_validate(ref_key_hash, value, level+"-->#{key}", invalid)
          else
            invalid << level + "-->#{key} should not be a Hash"
          end
        # Compare regular expressions since we are at the bottom level
        # (leaf in the Hash tree)
        else
          result = compare(reference[key], to_check[key])
          case result
          when :invalid_ref_type
            err_msg = "simplib::validate_deep_hash(): Check for " +
              level + "-->#{key} has invalid type '#{reference[key].class}'"
            raise ArgumentError.new(err_msg)

          when :invalid_check_type
            invalid << level + "-->#{key} #{to_check[key].class} cannot" +
              " be converted to string for comparison"

          when :failed_check
            invalid << level + "-->#{key} '#{to_check[key]}' must" +
              " validate against '/#{reference[key]}/'"
          end
        end
      else
        invalid << (level+"-->#{key} not in reference hash")
      end
    end
    return invalid
  end
end
