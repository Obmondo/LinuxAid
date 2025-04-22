Facter.add('snapshot') do

  setcode do
    Facter::Core::Execution.execute("ls -r /var/cache/packagesign/snapshots", on_fail: '')
  end
end
