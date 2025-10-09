require 'digest'

Puppet::Type.newtype(:wildfly_deployment) do
  desc 'Manages JBoss deployment'

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc 'Deployable name'
  end

  newparam(:source) do
    desc 'Deployment source file. (e.g. /tmp/file.war)'
  end

  newparam(:server_group) do
    desc 'Deployment target server-group. Domain mode only.'
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
    desc 'Management port. Defaults to 9990'
    defaultto 9990
  end

  newparam(:timeout) do
    desc 'Operation timeout. Defaults to 120'
    defaultto 300

    munge(&:to_i)
  end

  newparam(:operation_headers) do
    desc 'Operation headers.'
    defaultto {}

    validate do |value|
      raise("#{value} is not a Hash") unless value.is_a?(Hash)
    end
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
      Digest::SHA1.hexdigest(File.read(source)) if File.exist?(source)
    end

    def change_to_s(current_value, new_value)
      super(current_value, sha1sum?(@resource[:source]))
    end
  end
end
