require cassandra::java
include cassandra::optutils

class { 'cassandra::apache_repo':
  release => '310x',
  before  => Class['cassandra', 'cassandra::optutils'],
}

class { 'cassandra':
  commitlog_directory    => '/var/lib/cassandra/commitlog',
  data_file_directories  => ['/var/lib/cassandra/data'],
  hints_directory        => '/var/lib/cassandra/hints',
  saved_caches_directory => '/var/lib/cassandra/saved_caches',
  settings               => {
    'authenticator'               => 'PasswordAuthenticator',
    'authorizer'                  => 'CassandraAuthorizer',
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
}
