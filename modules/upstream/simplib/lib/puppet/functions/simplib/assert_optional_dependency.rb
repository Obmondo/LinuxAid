# Fails a compile if the system does not contain a correct version of the
# required module in the current environment.
#
# Provides a message about exactly which version of the module is required.
#
Puppet::Functions.create_function(:'simplib::assert_optional_dependency') do
  # @param source_module
  #   The name of the module containing the dependency information (usually the
  #   module that this function is being called from)
  #
  # @param target_module
  #   The target module to check. If not specified, all optional dependencies
  #   in the tree will be checked.
  #
  #   * This may optionally be the full module name with the author in
  #     `author/module` form which allows for different logic paths that can use
  #     multiple vendor modules
  #
  # @param dependency_tree
  #   The root of the dependency tree in the module's `metadata.json` that
  #   contains the optional dependencies.
  #
  #   * Nested levels should be separated by colons (`:`)
  #
  # @example Check for the 'puppet/foo' optional dependency
  #
  #   ### metadata.json ###
  #   "simp": {
  #     "optional_dependencies" [
  #       {
  #         "name": "puppet/foo",
  #         "version_requirement": ">= 1.2.3 < 4.5.6"
  #       }
  #     ]
  #   }
  #
  #   ### myclass.pp ###
  #   # Check all dependencies
  #   simplib::assert_optional_dependency($module_name)
  #
  #   # Check the module 'foo'
  #   simplib::assert_optional_dependency($module_name, 'foo')
  #
  #   # Check the module 'foo' by author 'puppet'
  #   simplib::assert_optional_dependency($module_name, 'puppet/foo')
  #
  #   # Check an alternate dependency target
  #   simplib::assert_optional_dependency($module_name, 'puppet/foo', 'my:deps')
  #
  # @return [None]
  #
  dispatch :assert_optional_dependency do
    required_param 'String[1]', :source_module
    optional_param 'String[1]', :target_module
    optional_param 'String[1]', :dependency_tree
  end

  def get_module_dependencies(dependency_tree_levels, module_metadata)
    _levels = Array(dependency_tree_levels.dup)
    current_level = _levels.shift
    metadata_level = module_metadata

    while !_levels.empty?
      if metadata_level[current_level]
        metadata_level = metadata_level[current_level]
        current_level = _levels.shift
      else
        return nil
      end
    end

    return metadata_level[current_level]
  end

  def check_dependency(module_name, module_dependency)
    require 'semantic_puppet'

    _module_author, _module_name = module_name.split('/')

    unless _module_name
      _module_name = _module_author.dup
      _module_author = nil
    end

    unless call_function('simplib::module_exist', _module_name)
      return "optional dependency '#{_module_name}' not found"
    end

    if module_dependency
      module_metadata = call_function('load_module_metadata', _module_name)

      if _module_author
        cmp_author = module_metadata['name'].strip.gsub('-','/').split('/').first
        unless _module_author.strip == cmp_author
          return %('#{module_name}' does not match '#{module_metadata['name']}')
        end
      end

      if module_dependency['version_requirement']
        begin
          version_requirement = SemanticPuppet::VersionRange.parse(module_dependency['version_requirement'])
        rescue ArgumentError
          return %(invalid version range '#{module_dependency['version_requirement']}' for '#{_module_name}')
        end

        module_version = module_metadata['version']

        begin
          module_version = SemanticPuppet::Version.parse(module_version)
        rescue ArgumentError
          return %(invalid version '#{module_version}' found for '#{_module_name}')
        end

        unless version_requirement.include?(module_version)
          return %('#{_module_name}-#{module_version}' does not satisfy '#{version_requirement}')
        end
      end
    end
  end

  def raise_error(msg, env)
    raise(Puppet::ParseError, %(assert_optional_dependency(): #{msg} in environment '#{env}'))
  end

  def assert_optional_dependency(
    source_module,
    target_module = nil,
    dependency_tree = 'simp:optional_dependencies'
  )

    current_environment = closure_scope.compiler.environment.to_s

    module_dependencies = get_module_dependencies(
      dependency_tree.split(':'),
      call_function(
        'load_module_metadata',
        source_module
      )
    )

    if module_dependencies
      if target_module
        tgt = target_module.gsub('-','/')

        if tgt.include?('/')
          target_dependency = module_dependencies.find {|d| d['name'].gsub('-','/') == tgt}
        else
          target_dependency = module_dependencies.find {|d| d['name'] =~ %r((/|-)#{tgt}$)}
        end

        if target_dependency
          result = check_dependency(tgt, target_dependency)

          raise_error(result, current_environment) if result
        else
          raise_error(%(module '#{target_module}' not found in metadata.json for '#{source_module}'), current_environment)
        end
      else
        results = []

        module_dependencies.each do |dependency|
          result = check_dependency(dependency['name'].gsub('-','/'), dependency)
          results << result if result
        end

        unless results.empty?
          raise_error(%(\n* #{results.join("\n* ")}\n), current_environment)
        end
      end
    end
  end
end
