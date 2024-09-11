#
# bool.rb
#
Puppet::Functions.create_function(:bool) do
  dispatch :bool do
    param 'Data', :arg
    return_type 'String'
  end


  def bool(x)
    return case x
           when nil
             ''
           when String
             !!x.count ? '1' : '0'
           else
             x ? '1' : '0'
           end
  end
end
