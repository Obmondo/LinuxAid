Puppet::Functions.create_function(:to_yn) do
  dispatch :to_yn do
    param 'Boolean', :arg
  end

  def to_yn(s)
    s and 'y' or 'n'
  end
end
