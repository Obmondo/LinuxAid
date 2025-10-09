Puppet::Type.newtype(:runlevel) do
  @doc = "Changes the system runlevel by re-evaluating the inittab or systemd link.
    Arguments:

    name
      - the runlevel to evaluate for the system

    persist
      - boolean value that determines whether or not to set as the default runlevel of the system

    Example:

        runlevel { '3': persist => true, }
  "

  def initialize(*args)
    super

    found_resource = nil

    unless catalog.resources.none? do |r|
      r.is_a?(Puppet::Type.type(:runlevel)) && (found_resource = r)
    end

      msg = "Duplicate declaration: Runlevel is already declared in file #{found_resource.file} at line #{found_resource.line}. Can not declare more than one instance of Runlevel."

      raise Puppet::Resource::Catalog::DuplicateResourceError, msg
    end
  end

  def runlevel_xlat(value)
    case value
    when 'rescue' then '1'
    when 'multi-user' then '3'
    when 'graphical' then '5'
    else value
    end
  end

  newparam(:name, namevar: true) do
    desc 'The target runlevel of the system'
    newvalues(%r{^[1-5]$}, 'rescue', 'multi-user', 'graphical')

    munge do |value|
      @resource.runlevel_xlat(value)
    end
  end

  newparam(:transition_timeout) do
    desc 'How many seconds to wait for a runlevel switch before failing'
    newvalues(%r{^\d+$})

    defaultto 60

    munge do |value|
      value.to_s.to_i
    end
  end

  newproperty(:level) do
    desc 'The target runlevel of the system. Defaults to what is specified in :name'
    newvalues(%r{^[1-5]$}, 'rescue', 'multi-user', 'graphical', 'default')

    defaultto 'default'

    munge do |value|
      if value == 'default'
        @resource[:name]
      else
        @resource.runlevel_xlat(value)
      end
    end

    def insync?(is)
      provider.level_insync?(should, is)
    end
  end

  newproperty(:persist) do
    desc 'Whether or not to save the runlevel as default.'
    newvalues(:true, :false)
    defaultto :true
  end
end
