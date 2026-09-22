# @summary Class for managing the Rustdesk software
#
# @param manage Boolean parameter to control management of Rustdesk module. Defaults to false.
#
# @param client_enable Boolean parameter to enable or disable the Rustdesk client. Defaults to false.
#
# @param client_extra_dependencies Array[String] parameter to install OS specific dependencies. Defaults to [].
#
# @param server_enable Boolean parameter to enable or disable the Rustdesk server. Defaults to false.
#
# @param server_extra_dependencies Array[String] parameter to install OS specific dependencies. Defaults to [].
#
# @groups management manage.
#
# @groups client client_enable, client_extra_dependencies.
#
# @groups server server_enable, server_extra_dependencies.
#
# @groups networking, domains.
class common::software::rustdesk (
  Boolean              $manage                    = false,

  Boolean              $client_enable             = false,
  Array[String]        $client_extra_dependencies = [],

  Boolean              $server_enable             = false,
  Array[String]        $server_extra_dependencies = [],
) {
  if $manage {
    include profile::software::rustdesk
  }
}
