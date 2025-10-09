# Generates a random password string.
#
# Terminates catalog compilation if the password cannot be created
# in the allotted time.
#
Puppet::Functions.create_function(:'simplib::gen_random_password') do
  # @param length Length of the new password.
  #
  # @param complexity Specifies the types of characters to be used in the password
  #   * `0` => Use only Alphanumeric characters (safest)
  #   * `1` => Use Alphanumeric characters and reasonably safe symbols
  #   * `2` => Use any printable ASCII characters
  #
  # @param complex_only Use only the characters explicitly added by the complexity rules
  #
  # @param timeout_seconds Maximum time allotted to generate
  #    the password; a value of 0 disables the timeout
  #
  # @return [String] Generated password
  #
  # @raise [RuntimeError] if password cannot be created within allotted time
  dispatch :gen_random_password do
    required_param 'Integer[8]',                   :length
    optional_param 'Integer[0,2]',                 :complexity
    optional_param 'Boolean',                      :complex_only
    optional_param 'Variant[Integer[0],Float[0]]', :timeout_seconds
  end

  def gen_random_password(length, complexity = nil, complex_only = false, timeout_seconds = 30)
    require 'timeout'
    passwd = ''
    Timeout.timeout(timeout_seconds) do
      lower_charlist = ('a'..'z').to_a
      upper_charlist = ('A'..'Z').to_a
      digit_charlist = ('0'..'9').to_a
      symbol_charlist = nil
      case complexity
      when 1
        symbol_charlist = ['@', '%', '-', '_', '+', '=', '~']
      when 2
        symbol_charlist = (' '..'/').to_a + ('['..'`').to_a + ('{'..'~').to_a
      end

      charlists = if symbol_charlist.nil?
                    [
                      lower_charlist,
                      upper_charlist,
                      digit_charlist,
                    ]
                  elsif complex_only == true
                    [
                      symbol_charlist,
                    ]
                  else
                    [
                      lower_charlist,
                      upper_charlist,
                      digit_charlist,
                      symbol_charlist,
                    ]
                  end

      last_list_rand = nil
      last_char_rand = nil
      Integer(length).times do |_i|
        rand_list_index = rand(charlists.length).floor

        if rand_list_index == last_list_rand
          rand_list_index -= 1
        end

        last_list_rand = rand_list_index

        rand_index = rand(charlists[rand_list_index].length).floor

        if rand_index == last_char_rand
          rand_index -= 1
        end

        passwd += charlists[rand_list_index][rand_index]

        last_char_rand = rand_index
      end
    end

    passwd
  end
end
# vim: set expandtab ts=2 sw=2:
