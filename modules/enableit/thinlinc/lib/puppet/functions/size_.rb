#
# size_.rb
#
Puppet::Functions.create_function(:size_) do
  dispatch :size_ do
    param 'Optional[Array]', :arg
    return_type 'Integer'
  end


  def size_(values, separator=' ')
    return 0 if values.nil?

    values.count
  end
end
