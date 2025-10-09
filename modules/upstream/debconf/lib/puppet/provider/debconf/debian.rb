# frozen_string_literal: true

require_relative '../../../puppet_x/stm/debconf'

Puppet::Type.type(:debconf).provide(:debian) do
  desc 'Manage debconf database entries on Debian based systems.'

  confine package_provider: 'apt'
  defaultfor package_provider: 'apt'

  #
  # The Debian debconf provider
  #

  def initialize(value = {})
    super(value)
    @property_hash = {}
  end

  # Fetch item properties
  def fetch
    Puppet.debug("Debconf: fetch #{resource[:item]} for #{resource[:package]}")

    PuppetX::Debconf.communicate(resource[:package]) do |debconf|
      value = debconf.get(resource[:item])

      if value
        Puppet.debug("Debconf: #{resource[:item]} = '#{value}'")
        @property_hash[:ensure] = :present
        @property_hash[:value] = value

        seen = debconf.seen?(resource[:item])
        Puppet.debug("Debconf: #{resource[:item]} seen flag is '#{seen}'")
        @property_hash[:seen] = seen
      else
        @property_hash[:ensure] = :absent
      end
    end
  end

  # Call debconf-set-selections to store the item values
  def flush
    Puppet.debug("Debconf: calling flush #{resource[:name]}")

    case @property_hash[:ensure]
    when :present
      IO.popen('/usr/bin/debconf-set-selections', 'w+') do |pipe|
        # Store type/value
        if @property_hash[:value]
          args = [resource[:package], resource[:item]]
          args << resource[:type]
          args << resource[:value]

          comm = args.join(' ')
          Puppet.debug("Debconf: debconf-set-selections #{comm}")
          pipe.puts(comm)
        end

        # Store seen flag
        unless resource[:seen].nil?
          args = [resource[:package], resource[:item]]
          args << 'seen'
          args << resource[:seen].to_s

          comm = args.join(' ')
          Puppet.debug("Debconf: debconf-set-selections #{comm}")
          pipe.puts(comm)
        end

        # Ignore remaining output from command
        pipe.close_write
        pipe.read(nil)
      end
    when :absent
      PuppetX::Debconf.communicate(resource[:package]) do |debconf|
        debconf.unregister(resource[:item])
      end
    end
  end

  def create
    Puppet.debug("Debconf: calling create #{resource[:name]}")

    @property_hash[:ensure] = resource[:ensure]
    @property_hash[:value]  = resource[:value]
    @property_hash[:seen]   = resource[:seen] if resource[:seen]
  end

  def destroy
    Puppet.debug("Debconf: calling destroy for #{resource[:name]}")

    @property_hash[:ensure] = :absent
  end

  def exists?
    Puppet.debug("Debconf: calling exists? for #{resource[:name]}")
    fetch if @property_hash.empty?

    @property_hash[:ensure] == :present
  end

  def value
    Puppet.debug("Debconf: calling get #{resource[:item]}")
    fetch if @property_hash.empty?

    @property_hash[:value]
  end

  def value=(val)
    Puppet.debug("Debconf: calling set #{resource[:item]} to #{val}")
    @property_hash[:item] = val
  end

  def seen
    Puppet.debug("Debconf: calling get seen flag of #{resource[:item]}")
    fetch if @property_hash.empty?

    @property_hash[:seen].to_s
  end

  def seen=(val)
    Puppet.debug("Debconf: calling set seen flag of #{resource[:item]} to #{val}")
    @property_hash[:seen] = val
  end
end
