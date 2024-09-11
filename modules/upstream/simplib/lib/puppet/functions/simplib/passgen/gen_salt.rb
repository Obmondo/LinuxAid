# Generates a salt
#
# * Terminates catalog compilation if the salt cannot be created
#   in the allotted time.
#
Puppet::Functions.create_function(:'simplib::passgen::gen_salt') do

  # @param timeout_seconds Maximum time allotted to generate the salt;
  #   a value of 0 disables the timeout
  #
  # @return [String] Generated salt
  #
  # @raise [Timeout::Error] if password cannot be created within allotted time
  #
  dispatch :gen_salt do
    optional_param 'Variant[Integer[0],Float[0]]', :timeout_seconds
  end

  def gen_salt(timeout_seconds = 30)
    # complexity of 0 is required to prevent disallowed
    # characters from being included in the salt
    salt = call_function('simplib::gen_random_password',
      16,    # length
      0,     # complexity
      false, # complex_only
      timeout_seconds
    )

    salt
  end
end

