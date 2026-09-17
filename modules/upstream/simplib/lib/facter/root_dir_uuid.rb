# Return the UUID of the partition holding the / directory
Facter.add('root_dir_uuid') do
  confine kernel: 'Linux'

  setcode do
    df_cmd = Facter::Core::Execution.which('df')
    blkid_cmd = Facter::Core::Execution.which('blkid')

    partition = Facter::Core::Execution.execute("#{df_cmd} -P /", on_fail: nil).strip.split("\n").last.split(' ').first

    uuid = Facter::Core::Execution.execute("#{blkid_cmd} -s UUID -o value #{partition}", on_fail: nil).strip

    uuid = nil if uuid.nil? || uuid.empty?

    uuid
  end
end
