#
# @summary A class to maintain the database schema.  Please note that cqlsh expects Python 2.7 to be installed. This may be a problem of older distributions (CentOS 6 for example).
#
# @param connection_tries [integer] How many times do try to connect to
#   Cassandra.  See also `connection_try_sleep`.
# @param connection_try_sleep [integer] How much time to allow between the
#   number of tries specified in `connection_tries`.
# @param cql_types [hash] Creates new `cassandra::schema::cql_type` resources.
# @param cqlsh_additional_options [string] Any additional options to be passed
#   to the `cqlsh` command.
# @param cqlsh_client_config [string] Set this to a file name
#   (e.g. '/root/.puppetcqlshrc') that will then be used to contain the
#   the credentials for connecting to Cassandra. This is a more secure option
#   than having the credentials appearing on the command line.  This option
#   is only available in Cassandra >= 2.1.
# @param cqlsh_client_tmpl [string] The location of the template for configuring
#   the credentials for the cqlsh client.  This is ignored unless
#   `cqlsh_client_config` is set.
# @param cqlsh_command [string] The full path to the `cqlsh` command.
# @param cqlsh_host [string] The host for the `cqlsh` command to connect to.
#   See also `cqlsh_port`.
# @param cqlsh_password [string] If credentials are require for connecting,
#   specify the password here.  See also `cqlsh_user`, `cqlsh_client_config`.
# @param cqlsh_port [integer] The host for the `cqlsh` command to connect to.
#   See also `cqlsh_host`.
# @param cqlsh_user [string] If credentials are required for connecting,
#   specify the password here. See also `cqlsh_password`,
#   `cqlsh_client_config`
# @param indexes [hash] Creates new `cassandra::schema::index` resources.
# @param keyspaces [hash] Creates new `cassandra::schema::keyspace` resources.
# @param permissions [hash] Creates new `cassandra::schema::permission`
#   resources.
# @param tables [hash] Creates new `cassandra::schema::table` resources.
# @param users [hash] Creates new `cassandra::schema::user` resources.
class cassandra::schema (
  $connection_tries         = 6,
  $connection_try_sleep     = 30,
  $cql_types                = {},
  $cqlsh_additional_options = '',
  $cqlsh_client_config      = undef,
  $cqlsh_client_tmpl        = 'cassandra/cqlshrc.erb',
  $cqlsh_command            = '/usr/bin/cqlsh',
  $cqlsh_host               = 'localhost',
  $cqlsh_password           = undef,
  $cqlsh_port               = 9042,
  $cqlsh_user               = 'cassandra',
  $indexes                  = {},
  $keyspaces                = {},
  $permissions              = {},
  $tables                   = {},
  $users                    = {},
  Boolean $use_scl          = $cassandra::params::use_scl,
  String[1] $scl_name       = $cassandra::params::scl_name,
) inherits cassandra::params {
  require 'cassandra'

  # Pass the SCL info to create_resources below as a hash
  $scl = {
    'use_scl'  => $use_scl,
    'scl_name' => $scl_name,
  }

  if $cqlsh_client_config != undef {
    file { $cqlsh_client_config :
      ensure  => file,
      group   => $facts['identity']['gid'],
      mode    => '0600',
      owner   => $facts['identity']['uid'],
      content => template( $cqlsh_client_tmpl ),
      before  => Exec['cassandra::schema connection test'],
    }

    $cmdline_login = "--cqlshrc=${cqlsh_client_config}"
  } else {
    if $cqlsh_password != undef {
      warning('You may want to consider using the cqlsh_client_config attribute')
      $cmdline_login = "-u ${cqlsh_user} -p ${cqlsh_password}"
    } else {
      $cmdline_login = ''
    }
  }

  $cqlsh_opts = "${cqlsh_command} ${cmdline_login} ${cqlsh_additional_options}"
  $cqlsh_conn = "${cqlsh_host} ${cqlsh_port}"

  # See if we can make a connection to Cassandra.  Try $connection_tries
  # number of times with $connection_try_sleep in seconds between each try.
  $connection_test_tmp = "${cqlsh_opts} -e 'DESC KEYSPACES' ${cqlsh_conn}"
  if $use_scl {
    $connection_test = "/usr/bin/scl enable ${scl_name} \"${connection_test_tmp}\""
  } else {
    $connection_test = $connection_test_tmp
  }

  exec { 'cassandra::schema connection test':
    command   => $connection_test,
    returns   => 0,
    tries     => $connection_tries,
    try_sleep => $connection_try_sleep,
    unless    => $connection_test,
  }

  # manage keyspaces if present
  if $keyspaces {
    create_resources('cassandra::schema::keyspace', $keyspaces, $scl)
  }

  # manage cql_types if present
  if $cql_types {
    create_resources('cassandra::schema::cql_type', $cql_types, $scl)
  }

  # manage tables if present
  if $tables {
    create_resources('cassandra::schema::table', $tables, $scl)
  }

  # manage indexes if present
  if $indexes {
    create_resources('cassandra::schema::index', $indexes, $scl)
  }

  # manage users if present
  if $users {
    create_resources('cassandra::schema::user', $users, $scl)
  }

  # manage permissions if present
  if $permissions {
    create_resources('cassandra::schema::permission', $permissions, $scl)
  }

  # Resource Ordering
  Cassandra::Schema::Keyspace <| |> -> Cassandra::Schema::Cql_type <| |>
  Cassandra::Schema::Keyspace <| |> -> Cassandra::Schema::Table <| |>
  Cassandra::Schema::Keyspace <| |> -> Cassandra::Schema::Permission <| |>
  Cassandra::Schema::Cql_type <| |> -> Cassandra::Schema::Table <| |>
  Cassandra::Schema::Table <| |> -> Cassandra::Schema::Index <| |>
  Cassandra::Schema::Table <| |> -> Cassandra::Schema::Permission <| |>
  Cassandra::Schema::Index <| |> -> Cassandra::Schema::User <| |>
  Cassandra::Schema::User <| |> -> Cassandra::Schema::Permission <| |>
}
