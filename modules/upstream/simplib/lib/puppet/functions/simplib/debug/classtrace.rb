# Prints out the stack of Puppet Classes and Defined Types that have been
# called up to this point
#
# WARNING: Uses **EXPERIMENTAL** features from Puppet, may break at any time.
Puppet::Functions.create_function(:'simplib::debug::classtrace', Puppet::Functions::InternalFunction) do

  # @param print
  #   Whether or not to print to the visual output
  #
  # @return [Array]
  #   The class trace
  dispatch :classtrace do
    scope_param()
    optional_param 'Boolean', :print
  end

  def classtrace(scope, print=true)
    class_stack = collate(scope).reverse

    if print
      msg = [
        "Simplib::Debug::Classtrace:",
        '    => ' + class_stack.join("\n    => ")
      ].join("\n")

      # This is only required when rspec is loaded
      if defined?(RSpec)
        $stderr.puts(msg)
      end

      Puppet.warning(msg)
    end

    return class_stack
  end

  private

  def collate(scope, retval=[])
    scope_s = scope.to_s
    if scope_s.start_with?('Scope(')
      scope_s = scope_s.split('Scope(').last[0..-2]
    end

    retval << scope_s

    unless scope.is_topscope?
      collate(scope.parent, retval)
    end

    retval
  end
end
