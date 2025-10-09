# frozen_string_literal: true

Facter.add(:augeasprovider_grub_version) do
  version =
    if File.exist?('/etc/default/grub')
      2
    elsif File.exist?('/boot/efi/EFI/redhat/grub.conf') || File.exist?('/boot/grub/menu.lst')
      1
    end

  setcode { version }
end
