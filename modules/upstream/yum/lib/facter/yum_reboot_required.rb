# frozen_string_literal: true

require 'English'

Facter.add(:yum_reboot_required) do
  confine osfamily: 'RedHat'
  setcode do
    if File.exist?('/usr/bin/needs-restarting')
      Facter::Core::Execution.execute('/usr/bin/needs-restarting --reboothint')
      !$CHILD_STATUS.success?
    end
  end
end
