Puppet::Type.type(:node_encrypted_file).provide(:ruby) do
  desc 'Ruby provider for the node_encrypted_file type'

  def exists?
    File.file?(resource[:path])
  end

  def create
    File.write(resource[:path], resource[:content].decrypted_value)
  end

  def destroy
    true
  end

  def content
    Puppet_X::Binford2k::NodeEncrypt::Value.new(File.read(resource[:path]))
  end

  def content=(value)
    File.write(resource[:path], resource[:content].decrypted_value)
  end
end
