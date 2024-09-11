require_relative '../../puppet_x/binford2k/node_encrypt'

Puppet::Type.newtype(:node_encrypted_file) do
  desc "Manage the content of a file by encrypting & decrypting with the agent certificate"

  ensurable do
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      raise Puppet::ParseError, 'The node_encrypted_file type does not support removal. Use the File type.'
    end
  end

  newparam(:path, :namevar => true) do
    desc 'The path of the managed file'
    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        fail Puppet::ParseError, "Paths must be fully qualified, not '#{value}'"
      end
    end
  end

  newproperty(:content) do
    desc 'Content for the file encrypted with the node_encrypt() function.'

    validate do |value|
      unless Puppet_X::Binford2k::NodeEncrypt.encrypted? value
        raise Puppet::ParseError, 'Pass only encrypted ciphertext to node_encrypted_file.'
      end
    end

    munge do |value|
      # This happens on the agent side, so yay?
      Puppet_X::Binford2k::NodeEncrypt::Value.new(value)
    end
  end

  if respond_to? :autobefore
    autobefore(:file) do
      self[:path]
    end
  else
    def autorequire(rel_catalog = nil)
      rel_catalog ||= catalog
      raise(Puppet::DevError, "You cannot add relationship without a catalog") unless rel_catalog

      reqs = super
      rel_catalog.resources.select{|x| x.is_a? Puppet::Type::File}.each do |res|
        next unless self[:path] == res[:path]
        reqs << Puppet::Relationship::new(self, res)
      end
      reqs
    end
  end
end
