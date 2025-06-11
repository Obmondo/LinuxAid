# Cassandra pre-requisites
include cassandra::datastax_repo
include cassandra::java

class { 'cassandra':
  package_name   => 'cassandra30',
  settings       => {
    'authenticator'               => 'AllowAllAuthenticator',
    'auto_bootstrap'              => false,
    'cluster_name'                => 'MyCassandraCluster',
    'commitlog_directory'         => '/var/lib/cassandra/commitlog',
    'commitlog_sync'              => 'periodic',
    'commitlog_sync_period_in_ms' => 10000,
    'data_file_directories'       => ['/var/lib/cassandra/data'],
    'endpoint_snitch'             => 'GossipingPropertyFileSnitch',
    'hints_directory'             => '/var/lib/cassandra/hints',
    'listen_interface'            => 'eth1',
    'num_tokens'                  => 256,
    'partitioner'                 => 'org.apache.cassandra.dht.Murmur3Partitioner',
    'saved_caches_directory'      => '/var/lib/cassandra/saved_caches',
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
  service_ensure => running,
  require        => Class['cassandra::datastax_repo', 'cassandra::java'],
}
