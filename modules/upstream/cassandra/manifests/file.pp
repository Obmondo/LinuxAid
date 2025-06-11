# A defined type for altering files relative to the configuration directory.
# @param file [string] The name of the file relative to the `config_path`.
# @param config_path [string] The path to the configuration directory.
# @param file_lines [string] If set, then the [create_resources]
#   (https://docs.puppet.com/puppet/latest/reference/function.html#createresources)
#   will be used to create an array of [file_line]
#   (https://forge.puppet.com/puppetlabs/stdlib#file_line) resources.
# @param service_refresh [boolean] Is the Cassandra service is to be notified
#   if the environment file is changed.
# @example
#   if $::memorysize_mb < 24576.0 {
#     $max_heap_size_in_mb = floor($::memorysize_mb / 2)
#   } elsif $::memorysize_mb < 8192.0 {
#     $max_heap_size_in_mb = floor($::memorysize_mb / 4)
#   } else {
#     $max_heap_size_in_mb = 8192
#   }
#
#   $heap_new_size = $::processorcount * 100
#
#   cassandra::file { "Set Java/Cassandra max heap size to ${max_heap_size_in_mb}.":
#     file       => 'cassandra-env.sh',
#     file_lines => {
#       'MAX_HEAP_SIZE' => {
#         line  => "MAX_HEAP_SIZE='${max_heap_size_in_mb}M'",
#         match => '^#?MAX_HEAP_SIZE=.*',
#       },
#     }
#   }
#
#   cassandra::file { "Set Java/Cassandra heap new size to ${heap_new_size}.":
#     file       => 'cassandra-env.sh',
#     file_lines => {
#       'HEAP_NEWSIZE'  => {
#         line  => "HEAP_NEWSIZE='${heap_new_size}M'",
#         match => '^#?HEAP_NEWSIZE=.*',
#       }
#     }
#   }
#   $tmpdir = '/var/lib/cassandra/tmp'
#
#   file { $tmpdir:
#     ensure => directory,
#     owner  => 'cassandra',
#     group  => 'cassandra',
#   }
#
#   cassandra::file { 'Set java.io.tmpdir':
#     file       => 'jvm.options',
#     file_lines => {
#       'java.io.tmpdir' => {
#         line => "-Djava.io.tmpdir=${tmpdir}",
#       },
#     },
#     require    => File[$tmpdir],
#   }
define cassandra::file (
  $file             = $title,
  $config_path      = $cassandra::config_path,
  $file_lines       = undef,
  $service_refresh  = true,
) {
  include cassandra
  include cassandra::params
  include stdlib

  $path = "${config_path}/${file}"

  if $file_lines != undef {
    if $service_refresh {
      $default_file_line = {
        path    => $path,
        require => Package['cassandra'],
        notify  => Service['cassandra'],
      }
    } else {
      $default_file_line = {
        path    => $path,
        require => Package['cassandra'],
      }
    }

    create_resources(file_line, $file_lines, $default_file_line)
  }
}
