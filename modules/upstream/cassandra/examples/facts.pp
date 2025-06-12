if $facts['cassandrarelease'] {
  notify { "Cassandra release: ${facts['cassandrarelease']}": }
} else {
  warning('cassandrarelease is not set!')
}

if $facts['cassandramajorversion'] {
  notify { "Cassandra major version: ${facts['cassandramajorversion']}": }
} else {
  warning('cassandramajorversion is not set!')
}

if $facts['cassandraminorversion'] {
  notify { "Cassandra minor version: ${facts['cassandraminorversion']}": }
} else {
  warning('cassandraminorversion is not set!')
}

if $facts['cassandrapatchversion'] {
  notify { "Cassandra patch version: ${facts['cassandrapatchversion']}": }
} else {
  warning('cassandrapatchversion is not set!')
}
