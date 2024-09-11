Puppet::Functions.create_function(:pow) do
  dispatch :pow do
    param 'Integer', :arg1
    param 'Integer', :arg2
  end

  def pow(i, j)
    i ** j
  end
end
