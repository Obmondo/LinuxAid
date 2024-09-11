# Returns the contents of /proc/cmdline as a hash
Facter.add('cmdline') do
  confine { Gem::Version.new(Facter.version) >= Gem::Version.new('2') }
  confine { File.exist?('/proc/cmdline') }

  setcode do
    retval = {}
    begin
      File.read('/proc/cmdline').chomp.split.each do |x|
        i,j = x.split('=')

        if retval.has_key?(i)
          retval[i] = [retval[i], j].flatten()
        else
          retval[i] = j
        end
      end
    rescue => details
      Facter.warn("Could not gather data from /proc/cmdline: #{details.message}")
    end
    retval
  end
end
