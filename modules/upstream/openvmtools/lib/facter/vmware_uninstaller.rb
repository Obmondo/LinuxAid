# frozen_string_literal: true

# Fact to discover the VMwareTools uninstaller path, if any.

Facter.add(:vmware_uninstaller) do
  confine :kernel do |os|
    os != 'windows'
  end
  setcode do
    Facter::Core::Execution.which('vmware-uninstall-tools.pl')
  end
end
