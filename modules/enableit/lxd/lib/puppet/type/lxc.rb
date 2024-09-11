require 'puppet/parameter/boolean'

Puppet::Type.newtype(:lxc) do
  @doc = 'Manage a LXC container using LXD.'

  ensurable

  def initialize(*args)
    super
  end

  newparam(:name, :namevar=>true) do
    desc "The name of the LXC container."
  end

  newproperty(:state) do

    newvalue(:running, :event => :lxc_started) do
      provider.start
    end

    newvalue(:stopped, :event => :lxc_stopped) do
      provider.stop
    end

    newvalue(:paused, :event => :lxc_paused) do
      provider.pause
    end

    defaultto :running
  end

  newparam(:arch) do
    desc "Architecture."
  end

  newparam(:os) do
    desc "OS/distribution name."
  end

  newparam(:release) do
    desc "OS/distribution release."
  end

  newparam(:serial) do
    desc "OS/distribution serial; often a timestamp of the image used to create the instance."
  end

  newproperty(:config) do
    desc "LXC container config."
    defaultto {}

    munge do |config|
      return config if config.is_a? Hash

      config.split(',').reduce({}) { |acc, c|
        k, v = c.split('=', 2)
        acc[k.strip] = v.strip
        acc
      }
    end

    def insync?(is)
      # We return only the keys that are given in @should; otherwise we'd need
      # to explicitly define all keys in the config and a lot of them are
      # irrelevant to us.

      # For some reason we get an array with a hash...
      real_should =
        case @should
        when Hash
          @should
        when Array
          Puppet.err "Aborting; config array has more than 1 value" if @should.count > 1
          @should.first
        else
          Puppet.err "Don't know how to handle a config of type #{@should.class}"
        end

      # Since `@should` should have the fewest keys we use this as our base to
      # avoid iterating over `is` which likely has more kv pairs
      real_is = real_should.reduce({}) { |acc, (k, v)|
        acc[k] = is[k]
        acc
      }

      real_is == real_should
    end
  end

  newparam(:created_at) do
    desc 'Read-only container creation time.'
  end

  newparam(:image_description) do
    desc 'Read-only container image description; will be set by LXC at creation time.'
  end

  newproperty(:devices) do
    desc 'Devices connected to the LXC. By default this is set by the profile; if defining this variable it should have a `root` key.'
  end

  newproperty(:ip) do
    desc 'IP address assigned to the LXC.'
  end

  newproperty(:profiles) do
    desc "Profiles applied to the instance."
    defaultto ['default']

    munge do |values|
      return case values
             when Array
               values
             when String
               values.split(',').map { |profile|
                 profile.strip
               }
             else
               Puppet.err 'Invalid type "#{values.class}"'
             end
    end

    def insync?(is)
      is == @should.first
    end
  end

  newproperty(:ephemeral, :boolean => true) do
    defaultto false

    def insync?(is)
      is == @should
    end
  end

  newparam(:last_used_at) do
    desc 'Read-only timestamp corresponding to the last start.'
  end

end
