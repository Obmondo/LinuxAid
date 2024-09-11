Puppet::Functions.create_function(:fact) do
  dispatch :fact do
    param 'String', :arg
  end

  def fact(f)
    facts = closure_scope['facts']

    raise NameError, "Unknown fact #{f}" if not facts.has_key? f

    facts[f]
  end
end
