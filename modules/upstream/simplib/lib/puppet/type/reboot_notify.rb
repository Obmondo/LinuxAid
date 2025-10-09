require 'puppet/parameter/boolean'

Puppet::Type.newtype(:reboot_notify) do
  @doc = 'Notifies users when a system reboot is required.

    This type creates a file at $target the contents of which
    provide a summary of the reasons why the system requires a
    reboot.

    NOTE: This type will *only* register entries on refresh. Any
    other use of the type will not report the necessary reboot.

    A reboot notification will be printed at each puppet run until
    the system is successfully rebooted.'

  ensurable do
    desc 'Whether the notification should be added or removed'
    defaultto(:present)

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name) do
    desc 'The item that is being modified that requires a reboot'
  end

  newparam(:reason) do
    desc 'An optional reason for rebooting'

    defaultto('modified')
  end

  newparam(:control_only, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc <<~EOM
      This resource is only for control and should not add an item to the notification list

      You may only have ONE resource with this set to `true` in your catalog
    EOM

    defaultto(:false)
  end

  newparam(:log_level) do
    desc <<~EOM
      Set the message log level for notifications

      This is only active with :control_only set to `true`
    EOM

    defaultto(:notice)
    newvalues(:alert, :crit, :debug, :notice, :emerg, :err, :info, :warning)

    munge do |value|
      value.to_s
    end
  end

  validate do
    if self[:control_only]
      existing_resource = catalog.resources.find { |res| (res.type == type) && res[:control_only] }

      if existing_resource
        err = ["You can only have one #{type} resource with :control_only set to 'true'"]
        err << "Conflicting resource found in file '#{existing_resource.file}' on line '#{existing_resource.line}'"

        raise(Puppet::Error, err.join("\n"))
      end
    end
  end

  # We only update on refresh
  def refresh
    provider.update if self[:ensure] == :present
  end
end
