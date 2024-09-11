Puppet::Functions.create_function(:to_yesno) do
  dispatch :to_yesno do
    param 'Boolean', :arg
  end

  def to_yesno(s)
    s and 'yes' or 'no'
  end
end
