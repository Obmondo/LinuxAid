#
# join_.rb
#
Puppet::Functions.create_function(:join_) do
  dispatch :join_ do
    param 'Optional[Array]', :arg
    optional_param 'Optional[String]', :arg
    return_type 'String'
  end


  def join_(values, separator=' ')
    return '' if values.nil?

    values.join(separator)
  end
end
