Facter.add('snapshot') do
  confine do
    File.directory?('/var/cache/packagesign/snapshots')
  end

  setcode do
    Dir.glob('/var/cache/packagesign/snapshots/*')
       .select { |f| File.directory?(f) }
       .map { |f| File.basename(f) }
       .sort
       .reverse
       .join("\n")
  end
end
