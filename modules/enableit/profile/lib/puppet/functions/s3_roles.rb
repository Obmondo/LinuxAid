# Error out when certain key's value are duplicate across the hash map
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
Puppet::Functions.create_function(:s3_roles) do
  dispatch :s3_roles do
    param Hash, :arguments
  end

  def s3_roles(arguments)
    if (arguments.length != 2) then
      raise(Puppet::ParseError, "s3_roles(): Wrong number of arguments "+
        "given #{arguments.length} for 2")
    end


    [
      'arn',
      'access_key_id',
      'shortid'
    ].each do |x|
      _x = arguments.reduce([]) do |acc, role|
        opts = role.values
        acc.append(opts[x])
      end

      if _x.uniq.length != _x.length then
        raise ArgumentError, "Found duplicate #{x} values in roles"
      end
    end
  end

end
