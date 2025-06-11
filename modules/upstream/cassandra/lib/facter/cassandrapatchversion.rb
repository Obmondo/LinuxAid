# Extract the patch version from the cassandrarelease fact.
# @caveats
#   Requires that the cassandrarelease has been successfully retrieved.
# @return [integer] The patch version of the Cassandra instance.
# @see cassandrarelease
Facter.add('cassandrapatchversion') do
  setcode do
    release = Facter.value(:cassandrarelease)
    release.split('.')[2].to_i if release
  end
end
