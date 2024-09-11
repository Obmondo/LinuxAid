Puppet::Type.newtype(:wildfly_resource) do
  @doc = 'Manages JBoss resources like datasources, messaging, ssl, modcluster, etc'

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:path, :namevar => true) do
    desc 'JBoss Resource Path'

    validate do |value|
      fail("Invalid resource path #{value}") unless value =~ %r{(\/[\w\-]+=[\w\-]+)}
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
  end

  newparam(:port) do
    desc 'Management port. Defaults to 127.0.0.1'
    defaultto 9990
  end

  newparam(:recursive) do
    desc 'Recursively manage resource. Defaults to false'
    defaultto false
  end

  newproperty(:state) do
    desc 'Resource state'
    defaultto {}

    validate do |value|
      value.is_a?(Hash)
    end

    def insync?(is)
      # Helper function to recursively sort
      def recursive_sort!(obj)
        case obj
        when Array
          obj.map!{|v| recursive_sort!(v)}.sort_by!{|v| (v.to_s rescue nil) }
        when Hash
          obj = Hash[Hash[obj.map{|k,v| [recursive_sort!(k),recursive_sort!(v)]}].sort_by{|k,v| [(k.to_s rescue nil), (v.to_s rescue nil)]}]
        else
          obj
        end
      end

      # Helper function to transform the hash
      def transform_hash(original, options={}, &block)
        original.inject({}){|result, (key,value)|
          value = if (options[:deep] && Hash === value)
                    transform_hash(value, options, &block)
                  else
                    value
                  end
          block.call(result,key,value)
          result
        }
      end

      # Helper function to transform values to strings
      def stringify_values(hash)
        transform_hash(hash, :deep => true) {|hash, key, value|
          if value.is_a? Numeric
            hash[key] = value.to_s
          else
            hash[key] = value
          end
        }
      end

      current_without_unused_keys = is.delete_if { |key, _| !should.keys.include? key }
      debug "Should: #{stringify_values(recursive_sort!(should)).inspect} Is: #{stringify_values(recursive_sort!(current_without_unused_keys)).inspect}"
      stringify_values(recursive_sort!(should)) == stringify_values(recursive_sort!(current_without_unused_keys))
    end

    def change_to_s(current_value, new_value)
      changed_keys = (new_value.to_a - current_value.to_a).collect { |key, _|  key }

      current_value = current_value.delete_if { |key, _| !changed_keys.include? key }.inspect
      new_value = new_value.delete_if { |key, _| !changed_keys.include? key }.inspect

      super(current_value, new_value)
    end
  end

  autorequire(:service) do
    ['wildfly']
  end
end
