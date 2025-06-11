# Extract the major version from the cassandrarelease fact.
# @caveats
#   Requires that the cassandrarelease has been successfully retrieved.
# @return [integer] The major version of the Cassandra instance.
# @see cassandrarelease
Facter.add('cassandramajorversion') do
  setcode do
    release = Facter.value(:cassandrarelease)
    release.split('.')[0].to_i if release
  end
end
