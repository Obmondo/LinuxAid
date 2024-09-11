lspci_re = /^(?<id>\w+:\w+.\d)\s(?<type>.*):\s(?<vendor>.*)/

lspci = Facter::Core::Execution.which('lspci')

# https://rubular.com/r/kjT71r4MSRntTc
Facter.add('raidcontrollers') do
  confine :kernel => 'Linux'
  confine :is_virtual => false
  confine { lspci }
  setcode do
    matches = []
    Facter::Core::Execution.execute('lspci')
                           .split("\n")
                           .grep(/controller/)
                           .map do |pci|
      x = lspci_re.match(pci)
      if x['type'] =~ /Serial Attached SCSI controller/ ||
         x['type'] =~ /RAID bus controller/
        matches << x['vendor']
      end
    end

    matches.sort.uniq
  end
end
