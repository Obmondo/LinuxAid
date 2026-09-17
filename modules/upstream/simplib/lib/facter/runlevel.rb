# _Description_
#
#
# Return the current system runlevel
#
Facter.add('runlevel') do
  confine kernel: 'Linux'
  setcode do
    if File.executable?('/sbin/runlevel')
      `"/sbin/runlevel"`.split.last
    end
  end
end
