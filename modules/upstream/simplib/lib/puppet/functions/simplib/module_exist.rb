# Determines if a module exists in the current environment
#
# If passed with an author, such as `simp/simplib` or `simp-simplib`, will
# return whether or not that *specific* module exists.
Puppet::Functions.create_function(:'simplib::module_exist') do
  # @param module_name The module name to check
  # @return [Boolean] Whether or not the module exists in the current environment
  dispatch :module_exist do
    required_param 'String[1]', :module_name
  end

  def module_exist(module_name) # rubocop:disable Naming/PredicateMethod
    author, name = module_name.split(%r{/|-})

    unless name
      name = author.dup
      author = nil
    end

    return false unless Puppet::Module.find(name, closure_scope.compiler.environment.to_s)
    return true unless author
    return true if author.strip == call_function('load_module_metadata', name)['name'].strip.split(%r{/|-}).first

    false
  end
end
