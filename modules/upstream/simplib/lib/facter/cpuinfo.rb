# Returns the contents of /proc/cpuinfo as a hash
# The numeric entries in this should be changed to their proper data types in
# the future

Facter.add('cpuinfo') do
  confine { Gem::Version.new(Facter.version) >= Gem::Version.new('2') }
  confine { File.exist?('/proc/cpuinfo') }

  setcode do
    retval = {}
    begin
    File.read('/proc/cpuinfo').split(/^\s*$/).each do |section|
      procinfo = section.split("\n").map{|x| x = x.split(':').map(&:strip)}

      entry_hash = {}
      procinfo.each do |entry|
        next if (!entry || entry.empty?)

        key = entry.first.gsub(/\s+/,'_')
        value = entry.last

        if key == 'flags'
          value = value.split(/\s+/)
        end

        entry_hash[key] = value
      end

      proc_id = entry_hash.delete('processor')

      retval[%(processor#{proc_id})] = entry_hash
    end
    rescue => details
      Facter.warn("Could not gather data from /proc/cpuinfo: #{details.message}")
    end
    retval
  end
end
