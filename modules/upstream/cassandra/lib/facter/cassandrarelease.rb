# Extract the release string from the running Cassandra instance.
#
# @resolution
#   Runs the command "nodetool version".
# @caveats
#   The Cassandra service needs to be running, otherwise the fact will be
# undefined.
# @return [string] The version string (e.g. 3.0.1).
Facter.add('cassandrarelease') do
  setcode do
    version = Facter::Util::Resolution.exec('nodetool version')
    version.match(%r{\d+\.\d+\.\d+}).to_s if version && version != ''
  end
end
