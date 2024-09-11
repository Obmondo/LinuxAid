# Determine whether or not FIPS is enabled on this system
# Returns: Boolean

# This is a native fact in some versions of Puppet but we don't want to lose it
# if it's not present.
if Facter.value('fips_enabled').nil?
  Facter.add('fips_enabled') do
    confine :kernel => 'Linux'

    setcode do
      status_file = '/proc/sys/crypto/fips_enabled'

      if File.exist?(status_file) && File.open(status_file, &:readline)[0].chr == '1'
        true
      else
        false
      end
    end
  end
end
