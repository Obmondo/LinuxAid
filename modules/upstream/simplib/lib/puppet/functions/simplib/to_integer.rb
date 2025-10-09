# Converts the argument into an `Integer`.
#
# Terminates catalog compilation if the argument's class
# does not respond to the `to_i()` Ruby method.
#
Puppet::Functions.create_function(:'simplib::to_integer') do
  # @param input The argument to convert into an `Integer`
  # @return [Integer] Converted input
  # @raise [RuntimeError] if ``input`` does not implement a ``to_i()``
  #   method
  dispatch :to_integer do
    required_param 'Any', :input
  end

  def to_integer(input)
    return input if input.is_a?(Integer)

    return input.to_i if input.respond_to?(:to_i)

    raise("simplib::to_integer(): Object type '#{input.class}' cannot be converted to an Integer")
  end
end
