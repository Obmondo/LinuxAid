Puppet::Type.newtype(:script_umask) do
  @doc = "Alters the umask settings in the passed file."

  newparam(:name) do
    isnamevar
    desc "The file to alter."

    validate do |value|
      value =~ /^\// or raise(ArgumentError,"Error: :name must be an absolute path")
    end
  end

  newproperty(:umask) do
    desc "The umask that should be set in the target file."
    defaultto '077'
    newvalues(/^[0-7]{3,4}$/)
  end

  autorequire(:file) do
    [self[:name]]
  end
end
