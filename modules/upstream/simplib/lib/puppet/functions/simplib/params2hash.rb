# Returns a Hash of the parameters of the calling resource
#
# This is meant to get the parameters of classes and defined types.
# The behavior when calling from other contexts is undefined
Puppet::Functions.create_function(:'simplib::params2hash', Puppet::Functions::InternalFunction) do
  # @param prune
  #   Parameters that you wish to exclude from the output
  #
  # @return [Hash]
  #   All in-scope parameters
  dispatch :params2hash do
    scope_param
    optional_param 'Array[String[1]]', :prune
  end

  def params2hash(scope, prune = [])
    param_hash = scope.resource.to_hash

    prune << :name if scope.resource.type == 'Class'

    prune.each do |to_prune|
      next if to_prune.nil?
      param_hash.delete(to_prune.to_sym)
    end

    param_hash
  end
end
