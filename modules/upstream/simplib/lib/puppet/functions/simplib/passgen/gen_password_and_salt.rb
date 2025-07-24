# Generates a password and salt
#
# * Password length, complexity and complex-only settings are specified by
#   the caller.
# * Salt length, complexity and complex-only settings are hard-coded
#   to values appropriate for a salt.
#
# * Terminates catalog compilation if the password and salt cannot be created
#   in the allotted time.
#
Puppet::Functions.create_function(:'simplib::passgen::gen_password_and_salt') do
  # @param length Length of the new password.
  #
  # @param complexity Specifies the types of characters to be used in the
  #   password
  #     * `0` => Use only Alphanumeric characters (safest)
  #     * `1` => Use Alphanumeric characters and reasonably safe symbols
  #     * `2` => Use any printable ASCII characters
  #
  # @param complex_only Use only the characters explicitly added by the
  #   complexity rules
  #
  # @param timeout_seconds Maximum time allotted to generate the password or
  #   the salt; a value of 0 disables the timeout
  #
  # @return [Array] Generated <password,salt> pair
  #
  # @raise [Timeout::Error] if password cannot be created within allotted time
  #
  dispatch :gen_password_and_salt do
    required_param 'Integer[8]',                   :length
    required_param 'Integer[0,2]',                 :complexity
    required_param 'Boolean',                      :complex_only
    required_param 'Variant[Integer[0],Float[0]]', :timeout_seconds
  end

  def gen_password_and_salt(length, complexity, complex_only, timeout_seconds)
    password = call_function('simplib::gen_random_password',
      length,
      complexity,
      complex_only,
      timeout_seconds)

    salt = call_function('simplib::passgen::gen_salt', timeout_seconds)

    [password, salt]
  end
end
