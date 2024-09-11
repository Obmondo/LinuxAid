# Validate that all passed values are either `true`, 'true',
# `false` or 'false'.
#
# Terminates catalog compilation if validation fails.
#
Puppet::Functions.create_function(:'simplib::validate_bool') do

  # @param values_to_validate One or more values to validate
  # @return [Nil]
  # @raise [RuntimeError] if validation fails
  # @example Passing validation
  #
  #     $iamtrue = true
  #     validate_bool(true)
  #     validate_bool("false")
  #     validate_bool("true")
  #     validate_bool(true, 'true', false, $iamtrue)
  #
  # @example Failing validation
  #     $some_array = [ true ]
  #     validate_bool($some_array)
  #     validate_bool('True')
  #     validate_bool('TRUE')
  #
  dispatch :validate_bool do
    required_repeated_param 'Variant[String,Boolean]', :values_to_validate
  end

  def validate_bool(*values_to_validate)
    valid_entries = [true, false, 'true', 'false']
    values_to_validate.each do |value|
      unless valid_entries.include?(value) then
        fail("simplib::validate_bool: '#{value}' is not a boolean.")
      end
    end
  end
end
