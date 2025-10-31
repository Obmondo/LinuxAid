# Create or drop user defined data types within the schema.
# @param keyspace [string] The name of the keyspace that the data type is to be associated with.
# @param ensure [present|absent] ensure the data type is created, or is dropped.
# @param fields [hash] A hash of the fields that will be components for the data type.
# @param cql_type_name [string] The name of the CQL type to be created.
# @example
#   cassandra::schema::cql_type { 'fullname':
#     keyspace => 'mykeyspace',
#     fields   => {
#       'fname' => 'text',
#       'lname' => 'text',
#     },
#   }
define cassandra::schema::cql_type (
  $keyspace,
  $ensure = present,
  $fields = {},
  $cql_type_name = $title,
  Boolean $use_scl = $cassandra::params::use_scl,
  String[1] $scl_name = $cassandra::params::scl_name,
) {
  include 'cassandra::schema'

  if $use_scl {
    $quote = '\"'
  } else {
    $quote = '"'
  }

  $read_script = "DESC TYPE ${keyspace}.${cql_type_name}"
  $read_command_tmp = "${cassandra::schema::cqlsh_opts} -e ${quote}${read_script}${quote} ${cassandra::schema::cqlsh_conn}"
  if $use_scl {
    $read_command = "/usr/bin/scl enable ${scl_name} \"${read_command_tmp}\""
  } else {
    $read_command = $read_command_tmp
  }

  if $ensure == present {
    $create_script1 = "CREATE TYPE IF NOT EXISTS ${keyspace}.${cql_type_name}"
    $create_script2 = join(join_keys_to_values($fields, ' '), ', ')
    $create_script = "${create_script1} (${create_script2})"
    $create_command_tmp = "${cassandra::schema::cqlsh_opts} -e ${quote}${create_script}${quote} ${cassandra::schema::cqlsh_conn}"
    if $use_scl {
      $create_command = "/usr/bin/scl enable ${scl_name} \"${create_command_tmp}\""
    } else {
      $create_command = $create_command_tmp
    }
    exec { $create_command:
      unless  => $read_command,
      require => Exec['cassandra::schema connection test'],
    }
  } elsif $ensure == absent {
    $delete_script = "DROP type ${keyspace}.${cql_type_name}"
    $delete_command_tmp = "${cassandra::schema::cqlsh_opts} -e ${quote}${delete_script}${quote} ${cassandra::schema::cqlsh_conn}"
    if $use_scl {
      $delete_command = "/usr/bin/scl enable ${scl_name} \"${delete_command_tmp}\""
    } else {
      $delete_command = $delete_command_tmp
    }
    exec { $delete_command:
      onlyif  => $read_command,
      require => Exec['cassandra::schema connection test'],
    }
  } else {
    fail("Unknown action (${ensure}) for ensure attribute.")
  }
}
