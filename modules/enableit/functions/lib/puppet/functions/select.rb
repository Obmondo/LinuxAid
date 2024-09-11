# Returns a hash with the keys from the source hash (first argument) selected in the second argument (array of the key names).
#
# *Examples:*
#
# $hash:
#   user1:
#     bla: bla
#   user2:
#     bla: bla
#
#     select($hash, ['user1'])
#
# Would return a hash containing only user1.
Puppet::Functions.create_function(:select) do

  def select(*arguments)
    if (arguments.size != 2) then
      raise(Puppet::ParseError, "delete(): Wrong number of arguments "+
        "given #{arguments.size} for 2")
    end

    hash = arguments[0]
    select = arguments[1]
    hash = hash.reject {|k,v| !select.include?(k)}
    hash
  end

end

