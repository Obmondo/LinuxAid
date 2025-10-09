# Returns the location of whatever called the item that called this function (two levels up)
#
# This is meant to be used inside other functions to tell you what is calling
# the given function so that you can return a meaningful error message and has
# limited utility outside of that situation.
#
# WARNING: Uses **EXPERIMENTAL** features from Puppet, may break at any time.
Puppet::Functions.create_function(:'simplib::caller', Puppet::Functions::InternalFunction) do
  # @param depth
  #   The level to walk backwards in the stack. May be useful for popping out
  #   of known function nesting
  #
  # @param print
  #   Whether or not to print to the visual output
  #
  # @return [Array]
  #   The caller
  dispatch :caller do
    scope_param
    optional_param 'Integer[0]', :depth
    optional_param 'Boolean', :print
  end

  def caller(_scope, depth = 1, print = false)
    calling_file = 'TOPSCOPE'

    stack_trace = call_function('simplib::debug::stacktrace', print)

    if stack_trace.size >= depth
      calling_file = stack_trace[-depth] if stack_trace[-depth]
    end

    calling_file
  end
end
