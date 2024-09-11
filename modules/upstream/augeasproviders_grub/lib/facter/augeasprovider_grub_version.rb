Facter.add(:augeasprovider_grub_version) do
  version =
    if File.exists?('/etc/default/grub')
      2
    elsif File.exists?('/boot/efi/EFI/redhat/grub.conf') || File.exists?('/boot/grub/menu.lst')
      1
    else
      nil
    end

  setcode { version }
end
