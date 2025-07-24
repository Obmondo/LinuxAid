# Detects if the system requires a reboot and why (if reason given)
#
# Expects a directory at /var/run/puppet/reboot_triggers with a file per reboot
# reason with an optional informative message within the file.
#
# Returns a hash of 'name' => 'reason' entries
#
# If no entries are found, simply returns false (the boolean)
#
Facter.add('reboot_required') do
  confine { Gem::Version.new(Facter.version) >= Gem::Version.new('2') }

  setcode do
    retval = {}

    Dir.glob('/var/run/puppet/reboot_triggers/*').each do |trigger|
      retval[File.basename(trigger)] = File.read(trigger).strip
    rescue => details
      Facter.warn("Could not read #{trigger}: #{details.message}")
    end

    retval = false if retval.empty?

    retval
  end
end
