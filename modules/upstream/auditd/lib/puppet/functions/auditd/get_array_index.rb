# @summary Returns a string that represents the first index of the specified element within the Array.
#
# Terminates catalog compilation if the element is not found within
# the array.
Puppet::Functions.create_function(:'auditd::get_array_index') do

  # @param element The element
  # @param array  The array
  # @param min_digits The minimum number of digits the index should be. 
  #   It will be '0'-padded to meet this number.
  # @return [String] Index of `element` in `array` represented as
  #   a string
  # @raise RuntimeError if `element` is not found within `array`
  #
  dispatch :get_array_index do
    required_param 'String',  :element
    required_param 'Array',   :array
    optional_param 'Integer', :min_digits
  end

  def get_array_index(element, array, min_digits = 2)
    index_num = array.index(element)
    if index_num.nil?
      fail("auditd::get_array_index: #{element} is not found in #{array}")
    end

    sprintf('%01$*2$d', index_num, min_digits)
  end
end
