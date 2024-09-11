Facter.add(:is_vagrant) do
  confine :is_virtual => true
  setcode do
    File.directory?('/vagrant')
  end
end
