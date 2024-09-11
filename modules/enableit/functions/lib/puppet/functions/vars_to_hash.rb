Puppet::Functions.create_function(:vars_to_hash) do
  dispatch :vars_to_hash do
    repeated_param 'String', :args
  end

  def vars_to_hash(*vars)
    scope = closure_scope
    vars.reduce({}) { |acc, var|
      acc[var] = scope[var]
      acc
    }
  end
end
