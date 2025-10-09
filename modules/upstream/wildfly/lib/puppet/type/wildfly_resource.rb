require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'puppet_x/wildfly/hash'))

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
    identity = lambda { |x| x }
    [
      [
        /^(.*):(.*):(.*)$/,
        [
          [:path, identity],
          [:host, identity],
          [:port, identity]
        ]
      ],
      [
        /^(.*):(.*)$/,
        [
          [:path, identity],
          [:host, identity]
        ]
      ],
      [
        /^([^:]+)$/,
        [
          [:path, identity]
        ]
      ]
    ]
  end

  newproperty(:state) do
    desc 'Resource state'
    defaultto {}

    validate do |value|
      raise("#{value} is not a Hash") unless value.is_a?(Hash)
    end

    def insync?(is)
      debug "Should: #{should.inspect} Is: #{is.inspect}"

      should.insync?(is)
    end

    def change_to_s(current_value, new_value)
      changed_keys = (new_value.to_a - current_value.to_a).collect { |key, _| key }

      current_value = current_value.delete_if { |key, _| !changed_keys.include? key }.deep_obfuscate_sensitive_values.inspect
      new_value = new_value.delete_if { |key, _| !changed_keys.include? key }.deep_obfuscate_sensitive_values.inspect

      super(current_value, new_value)
    end
  end
end
