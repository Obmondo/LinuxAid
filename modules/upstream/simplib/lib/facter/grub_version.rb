# _Description_
#
# Return the grub version installed on the system
#
Facter.add('grub_version') do
  setcode do
    if Facter::Core::Execution.which('grub')
      Facter::Core::Execution.execute('grub --version', on_fail: nil).split.last.delete('()')
    elsif Facter::Core::Execution.which('grub2-mkconfig')
      Facter::Core::Execution.execute('grub2-mkconfig --version', on_fail: nil).split.last.delete('()')
    elsif Facter::Core::Execution.which('grub-mkconfig')
      Facter::Core::Execution.execute('grub-mkconfig --version', on_fail: nil).split.last.delete('()')
    end
  end
end
