Puppet::Type.type(:reboot).provide :windows do
  confine operatingsystem: :windows
  defaultfor operatingsystem: :windows

  has_features :manages_reboot_pending
  attr_accessor :reboot_required

  def self.shutdown_command
    if File.exist?("#{ENV['SYSTEMROOT']}\\sysnative\\shutdown.exe")
      "#{ENV['SYSTEMROOT']}\\sysnative\\shutdown.exe"
    elsif File.exist?("#{ENV['SYSTEMROOT']}\\system32\\shutdown.exe")
      "#{ENV['SYSTEMROOT']}\\system32\\shutdown.exe"
    else
      'shutdown.exe'
    end
  end

  commands shutdown: shutdown_command

  def self.instances
    []
  end

  def when
    case @resource[:when]
    when :pending
      reboot_pending? ? :absent : :pending
    else
      :absent
    end
  end

  def when=(_value)
    return unless @resource[:when] == :pending
    if @resource.class.rebooting
      Puppet.debug('Reboot already scheduled; skipping')
    else
      @resource.class.rebooting = true
      reboot
    end
  end

  def cancel_transaction
    Puppet::Application.stop!
  end

  def reboot
    if @resource[:apply] == :finished && @resource[:when] == :pending
      Puppet.warning('The combination of `when => pending` and `apply => finished` is not a recommended or supported scenario. Please only use this scenario \
                      if you know exactly what you are doing. The puppet agent run will continue.')
    end

    if @resource[:apply] != :finished
      cancel_transaction
    end

    shutdown_path = command(:shutdown)
    unless shutdown_path
      raise ArgumentError, _('The shutdown.exe command was not found. On Windows 2003 x64 hotfix 942589 must be installed to access the 64-bit version of shutdown.exe from 32-bit version of ruby.exe.')
    end

    # Reason code
    # E P     4       1       Application: Maintenance (Planned)
    shutdown_cmd = [shutdown_path, '/r', '/t', @resource[:timeout], '/d', 'p:4:1', '/c', "\"#{@resource[:message]}\""].join(' ')
    async_shutdown(shutdown_cmd)
  end

  def async_shutdown(shutdown_cmd)
    Puppet.debug("Adding #{shutdown_cmd} to ruby's at_exit handler")
    at_exit { system shutdown_cmd }
  end

  def reboot_required?
    reboot_required
  end

  def reboot_pending?
    # http://gallery.technet.microsoft.com/scriptcenter/Get-PendingReboot-Query-bdb79542
    reasons = [
      :reboot_required,
      :component_based_servicing,
      :windows_auto_update,
      :pending_file_rename_operations,
      :package_installer,
      :package_installer_syswow64,
      :pending_computer_rename,
      :pending_dsc_reboot,
      :pending_ccm_reboot,
      :pending_domain_join,
    ]

    if @resource[:onlyif] && @resource[:unless]
      raise ArgumentError, _("You can't specify 'onlyif' and 'unless'")
    end

    reasons = @resource[:onlyif] if @resource[:onlyif]
    reasons -= @resource[:unless] if @resource[:unless]

    result = false

    reasons.each do |reason|
      result ||= send("#{reason}?".to_sym)
    end

    result
  end

  def vista_sp1_or_later?
    match = Facter[:kernelversion].value.match(%r{\d+\.\d+\.(\d+)})
    match.nil? ? false : match[1].to_i >= 6001
  end

  def component_based_servicing?
    return false unless vista_sp1_or_later?

    # http://msdn.microsoft.com/en-us/library/windows/desktop/aa370556(v=vs.85).aspx
    path = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
    pending = key_exists?(path)
    Puppet.debug("Pending reboot: HKLM\\#{path}") if pending
    pending
  end

  def windows_auto_update?
    path = 'SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
    pending = key_exists?(path)
    Puppet.debug("Pending reboot: HKLM\\#{path}") if pending
    pending
  end

  def pending_file_rename_operations?
    pending = false

    path = 'SYSTEM\CurrentControlSet\Control\Session Manager'
    with_key(path) do |reg|
      renames = begin
                  reg.read('PendingFileRenameOperations')
                rescue
                  nil
                end
      if renames
        pending = !renames[1].empty?
        if pending
          Puppet.debug('Pending reboot: HKLM\\PendingFileRenameOperations')
        end
      end
    end

    pending
  end

  def package_installer?
    # http://support.microsoft.com/kb/832475
    # 0x00000000 (0)	No pending restart.
    path = 'SOFTWARE\Microsoft\Updates'
    value = reg_value(path, 'UpdateExeVolatile')
    return false if value.nil? || value.zero?
    Puppet.debug("Pending reboot: HKLM\\#{path}\\UpdateExeVolatile=#{value}")
    true
  end

  def package_installer_syswow64?
    # http://support.microsoft.com/kb/832475
    # 0x00000000 (0)	No pending restart.
    path = 'SOFTWARE\Wow6432Node\Microsoft\Updates'
    value = reg_value(path, 'UpdateExeVolatile')
    return false if value.nil? || value.zero?
    Puppet.debug("Pending reboot: HKLM\\#{path}\\UpdateExeVolatile=#{value}")
    true
  end

  def pending_computer_rename?
    path = 'SYSTEM\CurrentControlSet\Control\ComputerName'
    active_name = reg_value("#{path}\\ActiveComputerName", 'ComputerName')
    pending_name = reg_value("#{path}\\ComputerName", 'ComputerName')
    if active_name && pending_name && active_name != pending_name
      Puppet.debug("Pending reboot: Computer being renamed from #{active_name} to #{pending_name}")
      true
    else
      false
    end
  end

  def pending_dsc_reboot?
    require 'win32ole'
    root = 'winmgmts:\\\\.\\root\\Microsoft\\Windows\\DesiredStateConfiguration'
    reboot = false

    begin
      dsc = WIN32OLE.connect(root)

      lcm = dsc.Get('MSFT_DSCLocalConfigurationManager')

      config = lcm.ExecMethod_('GetMetaConfiguration')
      reboot = config.MetaConfiguration.LCMState == 'PendingReboot'
    rescue # rubocop:disable Lint/HandleExceptions
      # WIN32OLE errors are very bad to diagnose.  In this case any errors are ignored.
    end

    Puppet.debug('Pending reboot: DSC LocalConfigurationManager LCMState') if reboot
    reboot
  end

  def pending_ccm_reboot?
    require 'win32ole'
    root = 'winmgmts:\\\\.\\root\\ccm\\ClientSDK'
    reboot = false

    begin
      ccm = WIN32OLE.connect(root)

      ccm_client_utils = ccm.Get('CCM_ClientUtilities')

      pending = ccm_client_utils.ExecMethod_('DetermineIfRebootPending')
      reboot = pending.ReturnValue.zero? && (pending.IsHardRebootPending || pending.RebootPending)
    rescue # rubocop:disable Lint/HandleExceptions
      # WIN32OLE errors are very bad to diagnose.  In this case any errors are ignored.
    end

    Puppet.debug('Pending reboot: CCM ClientUtilities') if reboot
    reboot
  end

  def pending_domain_join?
    path = 'SYSTEM\CurrentControlSet\Services\Netlogon\JoinDomain'
    pending = key_exists?(path)
    Puppet.debug("Pending reboot: HKLM\\#{path}") if pending
    pending
  end

  private

  def with_key(name)
    require 'win32/registry'

    Win32::Registry::HKEY_LOCAL_MACHINE.open(name, Win32::Registry::KEY_READ | 0x100) do |reg|
      yield reg if block_given?
    end

    true
  rescue
    false
  end

  def reg_value(path, value)
    rval = nil

    with_key(path) do |reg|
      rval = reg.read(value)[1]
    end

    rval
  end

  def key_exists?(path)
    with_key(path)
  end
end
