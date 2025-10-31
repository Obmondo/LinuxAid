# Create or drop tables within the schema.
# @param keyspace [string] The name of the keyspace.
# @param columns [hash] A hash of the columns to be placed in the table.
#   Optional if the table is to be absent.
# @param ensure [present|absent] Ensure a keyspace is created or dropped.
# @param options [array] Options to be added to the table creation.
# @param table [string] The name of the table.  Defaults to the name of the
#   resource.
# @example
#   cassandra::schema::table { 'users':
#     keyspace => 'mykeyspace',
#     columns  => {
#       'userid'      => 'int',
#       'fname'       => 'text',
#       'lname'       => 'text',
#       'PRIMARY KEY' => '(userid)',
#     },
#   }
define cassandra::schema::table (
  $keyspace,
  $ensure  = present,
  $columns = {},
  $options = [],
  $table   = $title,
  Boolean $use_scl = $cassandra::params::use_scl,
  String[1] $scl_name = $cassandra::params::scl_name,
) {
  include 'cassandra::schema'

  if $use_scl {
    $quote = '\"'
  } else {
    $quote = '"'
  }

  $read_script = "DESC TABLE ${keyspace}.${table}"
  $read_command_tmp = "${cassandra::schema::cqlsh_opts} -e ${quote}${read_script}${quote} ${cassandra::schema::cqlsh_conn}"
  if $use_scl {
    $read_command = "/usr/bin/scl enable ${scl_name} \"${read_command_tmp}\""
  } else {
    $read_command = $read_command_tmp
  }

  if $ensure == present {
    $create_script1 = "CREATE TABLE IF NOT EXISTS ${keyspace}.${table}"
    $cols_def = join(join_keys_to_values($columns, ' '), ', ')
    $cols_def_rm_collection_type = delete($cols_def, 'COLLECTION-TYPE ')

    if count($options) > 0 {
      $options_def = join($options, ' AND ')
      $create_script = "${create_script1} (${cols_def_rm_collection_type}) WITH ${options_def}"
    } else {
      $create_script = "${create_script1} (${cols_def_rm_collection_type})"
    }

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
    $delete_script = "DROP TABLE IF EXISTS ${keyspace}.${table}"
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
