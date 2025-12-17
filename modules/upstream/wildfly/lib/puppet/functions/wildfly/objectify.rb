# Converts a LIST of STRINGs and OBJECTs into an OBJECT of OBJECTs.
Puppet::Functions.create_function(:'wildfly::objectify') do
  dispatch :objectify do
    param 'Array[Variant[String, Hash[String, Any]]]', :input_list
    # return_type 'Hash[String, Hash[String, Any]]'
    return_type 'Hash'
  end

  def objectify(input_list)
    result_hash = {}

    input_list.each do |item|
      if item.is_a?(String)
        # If the item is a string, add it to the hash with a default key
        result_hash[item] = {}
      elsif item.is_a?(Hash)
        # If the item is a hash, merge it into the result_hash
        result_hash.merge!(item)
      else
        raise Puppet::ParseError, "Invalid data type in the list"
      end
    end

    result_hash
  end
end
