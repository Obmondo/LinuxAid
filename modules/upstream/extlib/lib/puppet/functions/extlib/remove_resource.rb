# frozen_string_literal: true

# @summary Removes a Resource or an Array of Resources from the catalog.
#
# This function provides a mechanism for removing a resource from the catalog
# that has already been added. You should only consider using this function as
# a last resort. If you are able to not add the resource in the first place, do
# that!  If a third party module that you have no control over and don't want
# to fork, unconditionally adds a resource you don't want, then _maybe_ this
# function can help you out.
#
# It can only remove resources that have already been added at the time the
# function is called.  ie. It is Puppet manifest evaluation order dependent on
# whether it removes what you want it to!
Puppet::Functions.create_function(:'extlib::remove_resource', Puppet::Functions::InternalFunction) do
  # @param resource The Resource to remove
  # @param soft_fail When set to true, only a warning will be omitted if the resource can't be found. By default an error will be raised.
  # @return [Undef] Returns nothing.
  dispatch :remove_resource do
    scope_param
    param 'Type[Resource]', :resource
    optional_param 'Boolean', :soft_fail
    return_type 'Undef'
  end

  # @param resources The Resources to remove
  # @param soft_fail When set to true, only a warning will be omitted if the resource can't be found. By default an error will be raised.
  # @return [Undef] Returns nothing.
  dispatch :remove_resources do
    scope_param
    param 'Array[Type[Resource]]', :resources
    optional_param 'Boolean', :soft_fail
    return_type 'Undef'
  end

  def remove_resources(scope, resources, soft_fail = nil)
    resources.each { |resource| remove_resource(scope, resource, soft_fail) }

    nil
  end

  def remove_resource(scope, resource, soft_fail = nil)
    type = Puppet::Pops::Evaluator::Runtime3ResourceSupport.find_resource_type(scope, resource.type_name)
    catalog_resource = scope.compiler.findresource(type, resource.title)

    if catalog_resource
      # To remove the resource, we reverse the actions from compiler.add_resource
      # See https://github.com/puppetlabs/puppet/blob/e227c27540975c25aa22d533a52424a9d2fc886a/lib/puppet/parser/compiler.rb#L77-L80
      scope.catalog.remove_resource(catalog_resource)
      scope.compiler.resources.delete(catalog_resource)
    else
      msg = "`remove_resource` couldn't remove resource #{resource.type_name}['#{resource.title}'] from the catalog as it wasn't found when `remove_resource` was called."

      raise Puppet::ParseError, msg unless soft_fail

      Puppet.warning msg
    end

    nil
  end
end
