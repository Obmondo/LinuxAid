# _Description_
#
# Set a fact to return the version of auditd that is installed.
# This is useful for applying the correct configuration file options.
#
Facter.add('auditd_version') do
  confine { File.exist?('/sbin/auditctl') && File.executable?('/sbin/auditctl') }
  setcode do
    %x{/sbin/auditctl -v}.chomp.split(/\s+/)[-1]
  end
end

Facter.add('auditd_major_version') do
  confine { File.exist?('/sbin/auditctl') && File.executable?('/sbin/auditctl') }
  setcode do
    Facter.value(:auditd_version).split('.')[0]
  end
end
