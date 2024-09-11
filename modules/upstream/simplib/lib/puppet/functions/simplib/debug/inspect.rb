# Prints out Puppet warning messages that display the passed variable, data
# type, and location.
#
# WARNING: Uses **EXPERIMENTAL** features from Puppet, may break at any time.
Puppet::Functions.create_function(:'simplib::debug::inspect', Puppet::Functions::InternalFunction) do

  # @param to_inspect
  #   The parameter that you wish to inspect
  #
  # @param print
  #   Whether or not to print to the visual output
  #
  # @return [Hash]
  #   Hash of the data that is printed
  dispatch :inspect do
    scope_param()
    required_param 'NotUndef', :to_inspect
    optional_param 'Boolean', :print
  end

  def inspect(scope, to_inspect, print=true)
    data = {
      :type        => to_inspect.class,
      :content     => to_inspect.to_pson,
      :module_name => scope.source.module_name,
      :file        => scope.source.file,
      :line        => scope.source.line
    }

    if print
      msg = [
        'Simplib::Debug::Inspect:',
        "Type => '#{data[:type]}'",
        "Content => '#{data[:content]}'"
      ]

      unless data[:module_name].empty?
        msg << "Module: '#{data[:module_name]}'"
      end

      if data[:file]
        msg << "Location: '#{data[:file]}:#{data[:line]}'"
      end

      msg = msg.join(' ')

      # This is only required when rspec is loaded
      if defined?(RSpec)
        $stderr.puts(msg)
      end

      Puppet.warning(msg)
    end

    return data
  end
end
