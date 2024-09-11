require 'digest'

Puppet::Type.newtype(:wildfly_deploy) do

  @doc = 'Manages JBoss deploy'

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc 'Deployable name'
  end

  newparam(:source) do
    desc 'Deployable source using http://, ftp://, or file://'
  end

  newparam(:username) do
    desc 'JBoss Management User'
  end

  newparam(:password) do
    desc 'JBoss Management User Password'
  end

  newparam(:host) do
    desc 'Host of Management API. Defaults to 127.0.0.1'
    defaultto '127.0.0.1'
  end

  newparam(:port) do
    desc 'Management port. Defaults to 127.0.0.1'
    defaultto 9990
  end

  newproperty(:content) do
    desc 'SHA1 of deployed content'
    defaultto ''

    def insync?(is)
      should = sha1sum?(@resource[:source])
      debug "Should SHA1: #{should} IS SHA1: #{is}"
      should == is
    end

    def sha1sum?(source)
      source_path = source.sub('file:', '')
      if File.exist?(source_path)
        return Digest::SHA1.hexdigest(File.read(source_path))
      end
    end
  end

  autorequire(:service) do
    ['wildfly']
  end
end
