# Apply this file. Examine the output and the resulting file.
# Grep the catalog for the contents of the file.
# Rejoice and be merry.
#
node_encrypt::file { '/tmp/foo':
  owner   => 'root',
  group   => 'root',
  content => 'This string will never appear in the catalog.',
}
