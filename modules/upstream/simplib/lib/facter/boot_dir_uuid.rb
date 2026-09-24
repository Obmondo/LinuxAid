# Return the UUID of the partition holding the /boot directory
Facter.add('boot_dir_uuid') do
  @df_cmd = Facter::Core::Execution.which('df')
  @blkid_cmd = Facter::Core::Execution.which('blkid')

  confine kernel: 'Linux'
  confine { File.exist?('/boot') }
  confine { !@df_cmd.nil? }
  confine { !@blkid_cmd.nil? }

  setcode do
    partition = Facter::Core::Execution.execute("#{@df_cmd} -P /boot", on_fail: nil).strip.split("\n").last.split(' ').first

    uuid = Facter::Core::Execution.execute("#{@blkid_cmd} -s UUID -o value #{partition}", on_fail: nil).strip

    uuid = nil if uuid.nil? || uuid.empty?

    uuid
  end
end
