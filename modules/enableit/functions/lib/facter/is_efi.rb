# Check if system is using EFI

Facter.add(:is_efi) do
  confine :kernel => :linux
  setcode do
    File.directory?('/sys/firmware/efi')
  end
end
