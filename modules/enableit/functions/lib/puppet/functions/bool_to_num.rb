Puppet::Functions.create_function(:bool_to_num) do
  dispatch :bool_to_num do
    param 'Boolean', :arg
  end

  def bool_to_num(s)
    s and 1 or 0
  end
end
