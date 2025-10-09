# @summary Return the status of auditding on the system
#
# The default entries of `enabled`, `enforcing`, and `kernel_enforcing` will always be returned.
#
# All other values will be pulled directly from `auditctl -s` and Integers will
# be converted to Integers. All other values will remain strings.
#
# @example Default Values
#
#   {
#     'enforcing',        => false # The state of `auditd` on the system
#     'kernel_enforcing', => false # The state of the kernel flag
#     'enabled'           => false # The `enabled` status from auditctl
#   }
#
Facter.add('simplib__auditd') do
  confine kernel: 'Linux'

  @auditctl = Facter::Util::Resolution.which('auditctl')
  @ps = Facter::Util::Resolution.which('ps')

  confine { !@auditctl.nil? }
  confine { !@ps.nil? }

  setcode do
    status = {
      'enforcing' => false,
      'kernel_enforcing' => false,
      'enabled' => 0,
    }

    audit_version = Facter::Core::Execution.exec("#{@auditctl} -v").split(%r{\s+}).last

    status['version'] = audit_version if audit_version && !audit_version.empty?

    auditctl_status = {}

    Facter::Core::Execution.exec("#{@auditctl} -s").lines.each do |l|
      l.strip!

      next if l.empty?

      k, v = l.split(%r{\s+}, 2)

      begin
        v = Integer(v)
      rescue
        nil
      end

      auditctl_status[k] = v
    end

    status = status.merge(auditctl_status)
    status['enabled'] = (status['enabled'] == 1) ? true : false

    if status['enabled']
      status['kernel_enforcing'] = true

      procs = Facter::Core::Execution.exec("#{@ps} -e").lines
      status['enforcing'] = procs.any? { |x| x =~ %r{\sauditd\Z} }
    else
      cmdline = Facter.value('cmdline') || {}
      status['kernel_enforcing'] = (cmdline['audit'].to_s == '1')
    end

    status
  end
end
