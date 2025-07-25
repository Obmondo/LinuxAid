# _Description_
#
# Return the minimum uid allowed
#
Facter.add('uid_min') do
  confine { File.exist?('/etc/login.defs') }

  setcode do
    uid_min = File.read('/etc/login.defs')
                  .lines(chomp: true)
                  .find { |line| line.split.first == 'UID_MIN' }
                  .to_s.split.last

    uid_min = '1000' if uid_min.nil? || uid_min.empty?

    uid_min
  end
end
