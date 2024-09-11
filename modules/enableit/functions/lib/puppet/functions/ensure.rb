Puppet::Functions.create_function(:ensure) do
  # Convert an "ensure" value into a boolean

  dispatch :ensure do
    param 'Data', :arg
  end

  def ensure(s)
    [:true, 'running', 'true', 'yes', true].member? s
  end
end
