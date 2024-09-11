Puppet::Type.newtype(:reboot) do
  @doc = _(<<-'EOT'
    Manages system reboots.  The `reboot` type is typically
    used in situations where a resource performs a change, e.g.
    package install, and a reboot is required to complete
    installation.  Only if the package is installed should the
    reboot be triggered.

    Sample usage:

        package { 'Microsoft .NET Framework 4.5':
          ensure          => installed,
          source          => '\\server\share\dotnetfx45_full_x86_x64.exe',
          install_options => ['/Passive', '/NoRestart'],
          provider        => windows,
        }
        reboot { 'after':
          subscribe       => Package['Microsoft .NET Framework 4.5'],
        }

    A reboot resource can also check if the system is in a
    reboot pending state, and if so, reboot the system.  For
    example, if you have a package that cannot be installed
    while a reboot is pending.

    Sample usage:

        reboot { 'before':
          when            => pending,
        }
        package { 'Microsoft .NET Framework 4.5':
          ensure          => installed,
          source          => '\\server\share\dotnetfx45_full_x86_x64.exe',
          install_options => ['/Passive', '/NoRestart'],
          provider        => windows,
          require         => Reboot['before'],
        }

    A reboot resource can also finish the run and then reboot the system.  For
    example, if you have a few packages that all require reboots but will not block
    each other during the run.

    Sample usage:

        package { 'Microsoft .NET Framework 4.5':
          ensure          => installed,
          source          => '\\server\share\dotnetfx45_full_x86_x64.exe',
          install_options => ['/Passive', '/NoRestart'],
          provider        => windows,
        }
        reboot { 'after_run':
          apply           => finished,
          subscribe       => Package['Microsoft .NET Framework 4.5'],
        }

    On windows we can limit the reasons for a pending reboot.

    Sample usage:

        reboot { 'renames only':
          when            => pending,
          onlyif          => 'pending_rename_file_operations',
        }
  EOT
  )

  feature :manages_reboot_pending, _('The provider can detect if a reboot is pending, and reboot as needed.')

  newparam(:name) do
    desc _('The name of the reboot resource.  Used for uniqueness.')
    isnamevar
  end

  newproperty(:when) do
    desc "When to check for, and if needed, perform a reboot. If `pending`,
      then the provider will check if a reboot is pending, and only
      if needed, reboot the system.  If `refreshed` then the reboot
      will only be performed in response to a refresh event from
      another resource, e.g. `package`."
    newvalue(:refreshed)
    newvalue(:pending, required_features: :manages_reboot_pending)
    defaultto :refreshed

    def insync?(is)
      case should
      when :refreshed
        true # we're always insync
      else
        super
      end
    end
  end

  newparam(:onlyif, required_features: [:manages_reboot_pending]) do
    desc "For pending reboots, only reboot if the reboot is pending
      for one of the supplied reasons."

    possible_values = [
      :reboot_required, :component_based_servicing, :windows_auto_update,
      :pending_file_rename_operations, :package_installer,
      :pending_computer_rename, :pending_dsc_reboot, :pending_ccm_reboot, :pending_domain_join
    ]

    validate do |values|
      if values == []
        raise ArgumentError, _('There must be at least one element in the list')
      end

      values = [values] unless values.is_a?(Array)

      values.each do |value|
        value = value.to_sym if value.is_a?(String)

        unless possible_values.include?(value)
          raise ArgumentError, _("value must be one of %{possible_values.join(', ')}") % { possible_values: 'translateable' }
        end
      end
    end

    munge do |values|
      values = [values] unless values.is_a?(Array)

      values.map(&:to_sym)
    end
  end

  newparam(:unless, required_features: [:manages_reboot_pending]) do
    desc 'For pending reboots, ignore the supplied reasons when checking pennding reboot'

    possible_values = [
      :reboot_required, :component_based_servicing, :windows_auto_update,
      :pending_file_rename_operations, :package_installer,
      :pending_computer_rename, :pending_dsc_reboot, :pending_ccm_reboot, :pending_domain_join
    ]

    validate do |values|
      if values == []
        raise ArgumentError, _('There must be at least one element in the list')
      end

      values = [values] unless values.is_a?(Array)

      values.each do |value|
        value = value.to_sym if value.is_a?(String)

        unless possible_values.include?(value)
          raise ArgumentError, _("value must be one of %{possible_values.join(', ')}") % { possible_values: 'translateable' }
        end
      end
    end

    munge do |values|
      values = [values] unless values.is_a?(Array)

      values.map(&:to_sym)
    end
  end

  newparam(:apply) do
    desc "When to apply the reboot. If `immediately`, then the provider
      will stop applying additional resources and apply the reboot once
      puppet has finished syncing. If `finished`, it will continue
      applying resources and then perform a reboot at the end of the
      run. The default is `immediately`."
    newvalues(:immediately, :finished)
    defaultto :immediately
  end

  newparam(:message) do
    desc _('The message to log when the reboot is performed.')

    validate do |value|
      if value.nil? || value == ''
        raise ArgumentError, _('A non-empty message must be specified.')
      end

      # Maximum command line length in Windows is 8191 characters, so this is
      # an approximation based on the other parts of the shutdown command
      if value.length > 8000
        raise ArgumentError, _('The given message must not exceed 8000 characters.')
      end
    end

    defaultto 'Puppet is rebooting the computer'
  end

  newparam(:timeout) do
    desc "The amount of time in seconds to wait between the time the reboot
      is requested and when the reboot is performed.  The default timeout
      is 60 seconds.  Note that this time starts once puppet has exited the
      current run."

    validate do |value|
      if value.to_s !~ %r{^\d+$}
        raise ArgumentError, _('The timeout must be an integer.')
      end
    end

    defaultto 60
  end

  @rebooting = false

  class << self
    attr_reader :rebooting
  end

  class << self
    attr_writer :rebooting
  end

  def refresh
    case self[:when]
    when :refreshed
      if self.class.rebooting
        Puppet.debug('Reboot already scheduled; skipping')
      else
        self.class.rebooting = true
        Puppet.notice("Scheduling system reboot with message: \"#{self[:message]}\"")
        provider.reboot
      end
    else
      Puppet.debug('Skipping reboot')
    end
  end
end
