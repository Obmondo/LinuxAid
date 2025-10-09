# Converts the argument into a `String`.
#
Puppet::Functions.create_function(:'simplib::to_string') do
  # @param input The argument to convert into a `String`
  # @return [String] Converted input
  dispatch :to_string do
    required_param 'Any', :input
  end

  def to_string(input)
    return input if input.is_a?(String)

    return input.to_s if input.respond_to?(:to_s)

    # Should not be able to get here with Puppet, especially since
    # Ruby provides a `to_s()` method for all objects
    raise("simplib::to_string(): Object type '#{input.class}' cannot be converted to a String")
  end
end
