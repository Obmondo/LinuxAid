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

  def module_exist(module_name)
    _module_author, _module_name = module_name.split(%r(/|-))

    unless _module_name
      _module_name = _module_author.dup
      _module_author = nil
    end

    if Puppet::Module.find(_module_name, closure_scope.compiler.environment.to_s)
      if _module_author
        if _module_author.strip == call_function('load_module_metadata', _module_name)['name'].strip.split(%r(/|-)).first
          return true
        else
          return false
        end
      else
        return true
      end
    else
      return false
    end
  end
end
