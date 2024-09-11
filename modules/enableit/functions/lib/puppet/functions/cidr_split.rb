# Split a CIDR into IP and netmask
Puppet::Functions.create_function(:cidr_split) do
  dispatch :cidr_split do
    param 'String', :cidr
  end

  def cidr_split(cidr)
    cidr.split '/'
  end
end
