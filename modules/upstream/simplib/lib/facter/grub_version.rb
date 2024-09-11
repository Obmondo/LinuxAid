# _Description_
#
# Return the grub version installed on the system
#
Facter.add('grub_version') do
  setcode do
    if Facter::Util::Resolution.which('grub') then
      grub_version = Facter::Util::Resolution.exec('grub --version').split.last.delete('()')
    elsif Facter::Util::Resolution.which('grub2-mkconfig') then
      grub_version = Facter::Util::Resolution.exec('grub2-mkconfig --version').split.last.delete('()')
    end
  end
end
