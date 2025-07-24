# Prints out a stacktrace of all files loaded up until the point where this
# function was called
#
# WARNING: Uses **EXPERIMENTAL** features from Puppet, may break at any time.
Puppet::Functions.create_function(:'simplib::debug::stacktrace', Puppet::Functions::InternalFunction) do
  # @param print
  #   Whether or not to print to the visual output
  #
  # @return [Array]
  #   The stack trace
  dispatch :stacktrace do
    scope_param
    optional_param 'Boolean', :print
  end

  def stacktrace(_scope, print = true)
    stack_trace = Puppet::Pops::PuppetStack.stacktrace.map { |x| x.join(':') }

    if print
      msg = [
        'Simplib::Debug::Stacktrace:',
        '    => ' + stack_trace.join("\n    => "),
      ].join("\n")

      # This is only required when rspec is loaded
      if defined?(RSpec)
        $stderr.puts(msg)
      end

      Puppet.warning(msg)
    end

    stack_trace
  end
end
