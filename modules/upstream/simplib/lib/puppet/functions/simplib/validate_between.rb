# Validate that the first value is between the second and third values
# numerically. The range is inclusive.
#
# Terminates catalog compilation if validation fails.
#
Puppet::Functions.create_function(:'simplib::validate_between') do
  # @param value Value to validate
  # @param min_value Minimum value that is valid
  # @param max_value Maximum value that is valid
  # @return [Nil]
  # @raise [RuntimeError] if validation fails
  #
  # @example Passing
  #   simplib::validate_between('-1', -3, 0)
  #   simplib::validate_between(7, 0, 60)
  #   simplib::validate_between(7.6, 7.1, 8.4)
  #
  # #example Failing
  #   simplib::validate_between('-1', 0, 3)
  #   simplib::validate_between(0, 1, 60)
  #   simplib::validate_between(7.6, 7.7, 8.4)
  #
  dispatch :validate_between do
    required_param 'Variant[String[1],Numeric]', :value
    required_param 'Numeric', :min_value
    required_param 'Numeric', :max_value
  end

  def validate_between(value, min_value, max_value)
    numeric_value = value.to_f
    return if (numeric_value >= min_value) && (numeric_value <= max_value)
    # The original method was used in SIMP modules as if it raised an
    # exception, so this implementation will work as expected.
    err_msg = "simplib::validate_between: '#{value}' is not between" \
              " '#{min_value}' and '#{max_value}'"
    raise(err_msg)
  end
end
