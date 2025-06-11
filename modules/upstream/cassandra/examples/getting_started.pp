#############################################################################
# This is for placing in the getting started section of the README file.
#############################################################################
# Install Cassandra 2.2.5 onto a system and create a basic keyspace, table
# and index.  The node itself becomes a seed for the cluster.
#
# Tested on CentOS 7
#############################################################################

# Cassandra pre-requisites
require cassandra::datastax_repo
require cassandra::system::sysctl
require cassandra::system::transparent_hugepage
require cassandra::java

class { 'cassandra::system::swapoff':
  device => '/dev/mapper/centos-swap',
  before => Class['cassandra'],
}

# Create a cluster called MyCassandraCluster which uses the
# GossipingPropertyFileSnitch.  In this very basic example
# the node itself becomes a seed for the cluster.

class { 'cassandra':
  commitlog_directory    => '/var/lib/cassandra/commitlog',
  data_file_directories  => ['/var/lib/cassandra/data'],
  hints_directory        => '/var/lib/cassandra/hints',
  package_name           => 'cassandra30',
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
  require                => Class['cassandra::datastax_repo', 'cassandra::system::sysctl', 'cassandra::java'],
}

class { 'cassandra::datastax_agent':
  settings => {
    'agent_alias'     => {
      'setting' => 'agent_alias',
      'value'   => 'foobar',
    },
    'stomp_interface' => {
      'setting' => 'stomp_interface',
      'value'   => 'localhost',
    },
    'async_pool_size' => {
      'ensure' => absent,
    },
  },
  require  => Class['cassandra'],
}

class { 'cassandra::optutils':
  package_name => 'cassandra30-tools',
  require      => Class['cassandra'],
}

class { 'cassandra::schema':
  cqlsh_password => 'cassandra',
  cqlsh_user     => 'cassandra',
  cqlsh_host     => $facts['networking']['ip'],
  indexes        => {
    'users_lname_idx' => {
      table    => 'users',
      keys     => 'lname',
      keyspace => 'mykeyspace',
    },
  },
  keyspaces      => {
    'mykeyspace' => {
      durable_writes  => false,
      replication_map => {
        keyspace_class     => 'SimpleStrategy',
        replication_factor => 1,
      },
    },
  },
  permissions    => {
    'Grant select permissions to spillman to all keyspaces' => {
      permission_name => 'SELECT',
      user_name       => 'spillman',
    },
    'Grant modify to to keyspace mykeyspace to akers'       => {
      keyspace_name   => 'mykeyspace',
      permission_name => 'MODIFY',
      user_name       => 'akers',
    },
    'Grant alter permissions to mykeyspace to boone'        => {
      keyspace_name   => 'mykeyspace',
      permission_name => 'ALTER',
      user_name       => 'boone',
    },
    'Grant ALL permissions to mykeyspace.users to gbennet'  => {
      keyspace_name   => 'mykeyspace',
      permission_name => 'ALTER',
      table_name      => 'users',
      user_name       => 'gbennet',
    },
  },
  tables         => {
    'users' => {
      columns  => {
        user_id       => 'int',
        fname         => 'text',
        lname         => 'text',
        'PRIMARY KEY' => '(user_id)',
      },
      keyspace => 'mykeyspace',
    },
  },
  users          => {
    'spillman' => {
      password => 'Niner27',
    },
    'akers'    => {
      password  => 'Niner2',
      superuser => true,
    },
    'boone'    => {
      password => 'Niner75',
    },
    'gbennet'  => {
      'password' => 'foobar',
    },
    'lucan'    => {
      'ensure' => absent,
    },
  },
}

$ram_sz_mb = floor($facts['memory']['system']['total_bytes'] / (1024*1024))
$half_of_ram = floor($ram_sz_mb / 2)
$quarter_of_ram = floor($ram_sz_mb / 4)
$max_heap_size_in_mb = max(min($half_of_ram, 1024), min($quarter_of_ram, 8192))
$heap_new_size = $facts['processors']['count'] * 100

cassandra::file { "Set Java/Cassandra max heap size to ${max_heap_size_in_mb}.":
  file       => 'cassandra-env.sh',
  file_lines => {
    'MAX_HEAP_SIZE' => {
      line  => "MAX_HEAP_SIZE='${max_heap_size_in_mb}M'",
      match => '^#?MAX_HEAP_SIZE=.*',
    },
  },
}

cassandra::file { "Set Java/Cassandra heap new size to ${heap_new_size}.":
  file       => 'cassandra-env.sh',
  file_lines => {
    'HEAP_NEWSIZE' => {
      line  => "HEAP_NEWSIZE='${heap_new_size}M'",
      match => '^#?HEAP_NEWSIZE=.*',
    },
  },
}

$tmpdir = '/var/lib/cassandra/tmp'

file { $tmpdir:
  ensure  => directory,
  owner   => 'cassandra',
  group   => 'cassandra',
  require => Package['cassandra'],
}

cassandra::file { 'Set java.io.tmpdir':
  file       => 'jvm.options',
  file_lines => {
    'java.io.tmpdir' => {
      line => "-Djava.io.tmpdir=${tmpdir}",
    },
  },
  require    => File[$tmpdir],
}
