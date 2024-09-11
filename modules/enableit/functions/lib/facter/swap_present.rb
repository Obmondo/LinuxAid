# Check if swap is present

Facter.add(:swap_present) do
  setcode do
    lambda {
      memory = Facter.value(:memory)
      return !!(memory['swap']) if memory

      # old Puppet is missing the `memory` fact
      swap = Facter.value(:swapsize_mb)
      return true if swap && Float(swap).positive?

      false
    }.call
  end
end
