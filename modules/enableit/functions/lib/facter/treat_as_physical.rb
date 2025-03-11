Facter.add('treat_as_physical') do
  setcode do
    virtual = Facter.value('virtual')
    ['kvm', 'physical', 'vmware', 'xenhvm', 'hyperv'].include?(virtual)
  end
end
