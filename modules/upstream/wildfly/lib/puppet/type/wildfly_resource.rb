require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'puppet_x/wildfly/deep_hash'))

Puppet::Type.newtype(:wildfly_resource) do
  desc 'Manages JBoss resources like datasources, messaging, ssl, modcluster, etc'

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:path) do
    desc 'JBoss Resource Path'

    isnamevar

    validate do |value|
      raise("Invalid resource path #{value}") unless value =~ %r{(\/[\w\-]+=[\w\-]+)}
    end
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

    isnamevar
  end

  newparam(:port) do
    desc 'Management port. Defaults to 9990'
    defaultto 9990

    munge(&:to_i)

    isnamevar
  end

  newparam(:secure) do
    desc 'Use TLS to connect with the management API'
    defaultto false 
  end

  newparam(:recursive) do
    desc 'Recursively manage resource. Defaults to false'
    defaultto false
  end

  newparam(:operation_headers) do
    desc 'Operation headers.'
    defaultto {}

    validate do |value|
      raise("#{value} is not a Hash") unless value.is_a?(Hash)
    end
  end

  def self.title_patterns
    [
      [
        /^(.*):(.*):(.*)$/,
        [
          [:path],
          [:host],
          [:port]
        ]
      ],
      [
        /^(.*):(.*)$/,
        [
          [:path],
          [:host]
        ]
      ],
      [
        /^([^:]+)$/,
        [
          [:path]
        ]
      ]
    ]
  end

  newproperty(:state) do
    include PuppetX::Wildfly::DeepHash

    desc 'Resource state'
    defaultto {}

    validate do |value|
      raise("#{value} is not a Hash") unless value.is_a?(Hash)
    end
  end
end
