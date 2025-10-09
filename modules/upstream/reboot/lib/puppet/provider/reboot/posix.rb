# frozen_string_literal: true

Puppet::Type.type(:reboot).provide :posix do
  desc _("POSIX provider for the reboot type.

  This provider handles rebooting for POSIX systems. It does not support
  HP-UX.")

  confine feature: :posix
  confine false: (Facter.value(:kernel) == 'HP-UX')
  defaultfor feature: :posix

  commands shutdown: 'shutdown'

  def shutdown_flags
    case Facter.value(:kernel)
    when 'SunOS'
      '-y -i 6 -g %d "%s"'
    else
      '-r +%d "%s"'
    end
  end
  private :shutdown_flags

  def self.instances
    []
  end

  def when
    :absent
  end

  def when=(value); end

  def cancel_transaction
    Puppet::Application.stop!
  end

  def reboot
    cancel_transaction if @resource[:apply] != :finished

    shutdown_path = command(:shutdown)
    raise ArgumentError, _('The shutdown command was not found.') unless shutdown_path

    timeout = @resource[:timeout].to_i
    unless Facter.value(:kernel) == 'SunOS'
      minutes = (timeout / 60.0).ceil
      Puppet.warning("Shutdown command on this system specifies time in minutes, rounding #{timeout} seconds up to #{minutes} minutes.") if timeout % 60 != 0
      timeout = minutes
    end

    flags = shutdown_flags % [timeout, @resource[:message]]
    shutdown_cmd = [shutdown_path, flags, '</dev/null', '>/dev/null', '2>&1', '&'].join(' ')
    async_shutdown(shutdown_cmd)
  end

  def async_shutdown(shutdown_cmd)
    Puppet.debug("Adding #{shutdown_cmd} to ruby's at_exit handler")
    pid = Process.pid
    at_exit { system shutdown_cmd if Process.pid == pid }
  end
end
