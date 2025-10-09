if $::cassandrarelease {
  notify { "Cassandra release: ${::cassandrarelease}": }
} else {
  warning('::cassandrarelease is not set!')
}

if $::cassandramajorversion {
  notify { "Cassandra major version: ${::cassandramajorversion}": }
} else {
  warning('::cassandramajorversion is not set!')
}

if $::cassandraminorversion {
  notify { "Cassandra minor version: ${::cassandraminorversion}": }
} else {
  warning('::cassandraminorversion is not set!')
}

if $::cassandrapatchversion {
  notify { "Cassandra patch version: ${::cassandrapatchversion}": }
} else {
  warning('::cassandrapatchversion is not set!')
}
