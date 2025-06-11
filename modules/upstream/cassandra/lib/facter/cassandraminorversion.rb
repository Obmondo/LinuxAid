# Extract the minor version from the cassandrarelease fact.
# @caveats
#   Requires that the cassandrarelease has been successfully retrieved.
# @return [integer] The minor version of the Cassandra instance.
# @see cassandrarelease
Facter.add('cassandraminorversion') do
  setcode do
    release = Facter.value(:cassandrarelease)
    release.split('.')[1].to_i if release
  end
end
