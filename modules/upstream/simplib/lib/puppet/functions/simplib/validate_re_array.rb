# Perform simple validation of a `String`, or `Array` of `Strings`,
# against one or more regular expressions.
#
# * Derived from the Puppet Labs stdlib validate_re.
# * Terminates catalog compilation if validation fails.
#
Puppet::Functions.create_function(:'simplib::validate_re_array') do

  # @param input String to be validated
  # @param regex Stringified regex expression (regex without the `//`
  #    delimiters)
  #
  # @param err_msg Optional error message to emit upon failure
  # @return [Nil]
  # @raise [RuntimeError] if validation fails
  #
  # @example Passing
  #   simplib::validate_re_array('one', '^one$')
  #
  # @example Failing
  #   validate_re_array('one', '^two')
  #
  # @example Custom Error Message
  #   validate_re_array($::puppetversion, '^2.7', 'The $puppetversion fact value does not match 2.7')
  #
  dispatch :validate_re_array_1_to_1 do
    required_param 'String', :input
    required_param 'String', :regex
    optional_param 'String', :err_msg
  end

  # @param input String to be validated
  # @param regex_list Array of stringified regex expressions (
  #    regexes without the `//` delimiters)
  #
  # @param err_msg Optional error message to emit upon failure
  # @return [Nil]
  # @raise [RuntimeError] if validation fails
  #
  # @example Passing
  #   simplib::validate_re_array('one', [ '^one', '^two' ])
  #
  # @example Failing
  #   validate_re_array('one', [ '^two', '^three' ])
  #
  # @example Custom Error Message
  #   $myvar = 'baz'
  #   validate_re_array($myvar, ['^foo', '^bar'], 'myvar does not begin with foo or bar')
  #
  dispatch :validate_re_array_1_to_n do
    required_param 'String', :input
    required_param 'Array', :regex_list
    optional_param 'String', :err_msg
  end

  # @param inputs Array of strings to be validated
  # @param regex Stringified regex expression (regex without the `//`
  #    delimiters)
  #
  # @param err_msg Optional error message to emit upon failure
  # @return [Nil]
  # @raise [RuntimeError] if validation fails
  #
  # @example Passing
  #   simplib::validate_re_array(['one-a', 'one-b'], [ '^one', '^two' ])
  #
  # @example Failing
  #   validate_re_array(['one-a', 'one-b'], [ '^two', '^three' ])
  #
  # @example Custom Error Message
  #   $myvar = ['hello', 'world']
  #   validate_re_array($myvar, '^foo', 'myvar elements do not begin with foo')
  #
  dispatch :validate_re_array_n_to_1 do
    required_param 'Array', :inputs
    required_param 'String', :regex
    optional_param 'String', :err_msg
  end

  # @param inputs Array of strings to be validated
  # @param regex_list Array of stringified regex expressions (
  #    regexes without the `//` delimiters)
  # @param err_msg Optional error message to emit upon failure
  # @return [Nil]
  # @raise [RuntimeError] if validation fails
  #
  # @example Passing
  #   simplib::validate_re_array(['one-a', 'one-b'], [ '^one', '^two' ])
  #
  # @example Failing
  #   validate_re_array(['one-a', 'one-b'], [ '^two', '^three' ])
  #
  # @example Custom Error Message
  #   $myvar = ['hello', 'world']
  #   validate_re_array($myvar, ['^foo', '^bar'], 'myvar elements do not begin with foo or bar')
  #
  dispatch :validate_re_array do
    required_param 'Array', :inputs
    required_param 'Array', :regex_list
    optional_param 'String', :err_msg
  end

  def validate_re_array_1_to_1(input, regex, err_msg=nil)
    validate_re_array([ input ], [ regex ], err_msg)
  end

  def validate_re_array_n_to_1(inputs, regex, err_msg=nil)
    validate_re_array(inputs, [ regex ], err_msg)
  end

  def validate_re_array_1_to_n(input, regex_list, err_msg=nil)
    validate_re_array([ input ], regex_list, err_msg)
  end

  def validate_re_array(inputs, regex_list, err_msg=nil)

    inputs.each do |to_check|
      valid = false
      regex_list.each do |re_str|
        if "#{to_check}" =~ Regexp.compile(re_str)
          valid = true
          break
        end
      end

      # Bail at the first failure.
      unless valid
        msg = err_msg || "simplib::validate_re_array(): #{to_check.inspect} does not match #{regex_list.inspect}"
        fail(msg)
      end
    end

  end
end
