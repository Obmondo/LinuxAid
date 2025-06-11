#############################################################################
# Specify different storage locations
#############################################################################

# Cassandra pre-requisites
include cassandra::datastax_repo
include cassandra::java

# Specify the storage locations
$commitlog_directory = '/appdata/cassandra/commitlog'
$data_file_directory = '/appdata/cassandra/data'
$saved_caches_directory = '/appdata/cassandra/saved_caches'

file { '/appdata':
  ensure => directory,
  mode   => '0755',
  before => File['/appdata/cassandra'],
}

file { '/appdata/cassandra':
  ensure => directory,
  mode   => '0755',
  before => Class['cassandra'],
}

# Create a cluster called MyCassandraCluster which uses the
# GossipingPropertyFileSnitch.  In this very basic example
# the node itself becomes a seed for the cluster.

class { 'cassandra':
  commitlog_directory    => $commitlog_directory,
  data_file_directories  => [$data_file_directory],
  saved_caches_directory => $saved_caches_directory,
  settings               => {
    'authenticator'               => 'PasswordAuthenticator',
    'cluster_name'                => 'MyCassandraCluster',
    'commitlog_sync'              => 'periodic',
    'commitlog_sync_period_in_ms' => 10000,
    'endpoint_snitch'             => 'GossipingPropertyFileSnitch',
    'listen_address'              => $facts['networking']['ip'],
    'partitioner'                 => 'org.apache.cassandra.dht.Murmur3Partitioner',
    'seed_provider'               => [
      {
        'class_name' => 'org.apache.cassandra.locator.SimpleSeedProvider',
        'parameters' => [
          {
            'seeds' => $facts['networking']['ip'],
          },
        ],
      },
    ],
    'start_native_transport'      => true,
  },
  service_ensure         => running,
  require                => Class['cassandra::datastax_repo', 'cassandra::java'],
}
