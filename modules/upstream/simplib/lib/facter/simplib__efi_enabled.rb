# _Description_
#
# Return true if system booted via EFI
#
Facter.add('simplib__efi_enabled') do
  confine kernel: 'Linux'

  setcode do
    File.exist?('/sys/firmware/efi')
  end
end
