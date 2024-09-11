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

  def gen_random_password(length, complexity=nil, complex_only=false, timeout_seconds = 30)
    require 'timeout'
    passwd = ''
    Timeout::timeout(timeout_seconds) do
      default_charlist = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
      specific_charlist = nil
      case complexity
        when 1
          specific_charlist = ['@','%','-','_','+','=','~']
        when 2
          specific_charlist = (' '..'/').to_a + ('['..'`').to_a + ('{'..'~').to_a
        else
      end

      unless specific_charlist.nil?
        if complex_only == true
          charlists = [
            specific_charlist
          ]
        else
          charlists = [
            default_charlist,
            specific_charlist
          ]
        end

      else
        charlists = [
          default_charlist
        ]
      end

      index = 0
      Integer(length).times do |i|
        passwd += charlists[index][rand(charlists[index].length-1)]
        index += 1
        index = 0 if index == charlists.length
      end
    end

    return passwd
  end

end
# vim: set expandtab ts=2 sw=2:
