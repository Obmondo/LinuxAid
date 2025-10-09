# _Description_
#
# Set a fact to return the version of auditd that is installed.
# This is useful for applying the correct configuration file options.
#
Facter.add('auditd_version') do
  confine kernel: 'Linux'

  setcode do
    auditd_facts = Facter.value('simplib__auditd')
    Facter.value('simplib__auditd')['version'] if auditd_facts
  end
end

Facter.add('auditd_major_version') do
  confine kernel: 'Linux'

  setcode do
    auditd_version = Facter.value('auditd_version')
    auditd_version&.split('.')&.first
  end
end
