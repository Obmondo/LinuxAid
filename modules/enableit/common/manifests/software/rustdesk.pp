# @summary Class for managing the Rustdesk software
#
# @param manage Boolean parameter to control management of Rustdesk module. Defaults to false.
#
# @param client_enable Boolean parameter to enable or disable the Rustdesk client. Defaults to false.
#
# @param client_version SemVer parameter to control Rustdesk client version. Defaults to 1.4.3.
#
# @param client_extra_dependencies Array[String] parameter to install OS specific dependencies. Defaults to [].
#
# @param server_enable Boolean parameter to enable or disable the Rustdesk server. Defaults to false.
#
# @param server_version SemVer parameter to control Rustdesk server version. Default to 1.7.1.
#
# @param server_extra_dependencies Array[String] parameter to install OS specific dependencies. Defaults to [].
#
# @groups management manage.
#
# @groups client client_enable, client_version, client_extra_dependencies.
#
# @groups server server_enable, server_version, server_extra_dependencies.
#
class common::software::rustdesk (
  Boolean             $manage                    = false,

  Boolean             $client_enable             = false,
  Array[String]       $client_extra_dependencies = [],
  Eit_types::Version  $client_version            = '1.4.3',

  Boolean             $server_enable             = false,
  Array[String]       $server_extra_dependencies = [],
  Eit_types::Version  $server_version            = '1.7.1',
) {
  if $manage {
    include profile::software::rustdesk
  }
}
