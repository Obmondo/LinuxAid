# _Description_
#
# Set a fact with the location of the audit sample rules
#
# Current output is a string containing the location of the audit sample rules
#
Facter.add('auditd_sample_ruleset_location') do
  confine :kernel => 'Linux'

  confine do
    File.directory?('/usr/share/audit/sample-rules') || !Dir.glob('/usr/share/doc/audit*/rules').empty?
  end

  setcode do

    retval = '/usr/share/audit/sample-rules' if File.directory?('/usr/share/audit/sample-rules')
    retval = Dir.glob('/usr/share/doc/audit*/rules').first if !Dir.glob('/usr/share/doc/audit*/rules').empty?

    retval
  end
end
