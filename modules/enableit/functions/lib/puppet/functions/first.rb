# Return the first non-undef value from supplied array.
Puppet::Functions.create_function(:first) do
  dispatch :first do
    param 'Array[Data]', :arg
  end

  def first(ss)
    ss.select { |x| !!x }.first
  end
end
