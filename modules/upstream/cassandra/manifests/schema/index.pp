# Create or drop indexes within the schema.
# @param ensure [present|absent] Create or dro[ the index.
# @param class_name [string] The name of the class to be associated with an
#   index when creating a custom index.
# @param index [string] The name of the index.  Defaults to the name of the
#   resource.
# @param keys [string] The columns that the index is being created on.
# @param keyspace [string] The name the keyspace that the index is to be associated
#   with.
# @param options [string] Any options to be added to the index.
# @param table [string] The name of the table that the index is to be associated with.
define cassandra::schema::index (
  $keyspace,
  $table,
  $ensure     = present,
  $class_name = undef,
  $index      = $title,
  $keys       = undef,
  $options    = undef,
  Boolean $use_scl = $cassandra::params::use_scl,
  String[1] $scl_name = $cassandra::params::scl_name,
) {
  include 'cassandra::schema'

  if $use_scl {
    $quote = '\"'
  } else {
    $quote = '"'
  }

  # Fully qualified index name.
  $fqin = "${keyspace}.${index}"
  # Fully qualified table name.
  $fqtn = "${keyspace}.${table}"

  $read_script = "DESC INDEX ${fqin}"
  $read_command_tmp = "${cassandra::schema::cqlsh_opts} -e ${quote}${read_script}${quote} ${cassandra::schema::cqlsh_conn}"
  if $use_scl {
    $read_command = "/usr/bin/scl enable ${scl_name} \"${read_command_tmp}\""
  } else {
    $read_command = $read_command_tmp
  }

  if $ensure == present {
    if $class_name != undef {
      $create_part1 = "CREATE CUSTOM INDEX IF NOT EXISTS ${index} ON ${keyspace}.${table}"
    } else {
      $create_part1 = "CREATE INDEX IF NOT EXISTS ${index} ON ${keyspace}.${table}"
    }

    if $class_name != undef {
      $create_part2 = "${create_part1} (${keys}) USING '${class_name}'"
    } else {
      $create_part2 = "${create_part1} (${keys})"
    }

    if $options != undef {
      $create_script = "${create_part2} WITH OPTIONS = ${options}"
    } else {
      $create_script = $create_part2
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
    $delete_script = "DROP INDEX ${fqin}"
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
