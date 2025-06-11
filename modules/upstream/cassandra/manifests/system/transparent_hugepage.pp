# Disable Transparant Huge Pages as suggested in
# http://docs.datastax.com/en/landing_page/doc/landing_page/recommendedSettingsLinux.html.
# @param path [string] The full path to the file for checking/setting
#   if Transparent Hugepages is enabled.
# @see cassandra::params
class cassandra::system::transparent_hugepage (
  $path = '/sys/kernel/mm/transparent_hugepage/defrag',
) inherits cassandra::params {
  exec { 'Disable Java Hugepages':
    command => "/bin/echo never > ${path}",
    path    => ['/bin', '/usr/bin'],
    unless  => "grep -q '\\[never\\]' ${path}",
  }
}
