Facter.add('snapshot') do

  confine :hostname => 'dkcphrepo01'

  setcode do
    Facter::Core::Execution.execute("ls -r /var/cache/packagesign/snapshots")
  end
end
