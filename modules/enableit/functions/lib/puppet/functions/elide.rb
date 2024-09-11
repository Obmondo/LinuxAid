# Remove values from array or hash
#
# frozen_string_literal: true
Puppet::Functions.create_function(:elide) do
  dispatch :elide do
    param 'Variant[Array[Data],Hash]', :input
    optional_param 'Data', :arg
  end

  def elide(input, value=nil)
    case input
    when Hash
      input.reject {|k,v| v == value}
    when Array
      input.reject {|v| v == value}
    end
  end
end
