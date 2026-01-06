
# @summary Class for managing the OpenVAS scanner
#
# @param install_dir The directory for installation. Defaults to '/opt/obmondo/docker-compose/openvas'.
#
# @param install Whether to install the scanner. Defaults to true.
#
# @param web_bind_address The web bind address. Defaults to '127.0.0.1'.
#
# @param web_port The port for the web interface. Defaults to 9392.
#
# @param openvasd_mode The mode for openvasd. Defaults to 'service_notus'.
#
# @param openvasd_addressport The address and port for openvasd. Defaults to '0.0.0.0:80'.
#
# @param storage_path The path for storage. Defaults to '/var/lib/openvas/22.04/vt-data/nasl'.
#
# @param registry The registry for openvas. Defaults to 'registry.community.greenbone.net/community'.
#
# @param vulnerability_tests_version The version for vulnerability tests. Defaults to '202502250742'.
#
# @param notus_data_version The version for notus data. Defaults to '202502250410'.
#
# @param scap_data_version The version for SCAP data. Defaults to '202502240506'.
#
# @param cert_bund_data_version The version for cert bundle data. Defaults to '202502250409'.
#
# @param dfn_cert_data_version The version for DFN cert data. Defaults to '202502250401'.
#
# @param data_objects_version The version for data objects. Defaults to '202502250505'.
#
# @param report_formats_version The version for report formats. Defaults to '202502250500'.
#
# @param gpg_data_version The version for GPG data. Defaults to '1.1.0'.
#
# @param redis_server_version The version for Redis server. Defaults to '1.1.0'.
#
# @param pg_gvm_version The version for PostgreSQL GVM. Defaults to '22.6.7'.
#
# @param gsa_version The version for GSA. Defaults to '24.3.0'.
#
# @param gvmd_version The version for GVMD. Defaults to '25'.
#
# @param openvas_scanner_version The version for OpenVAS scanner. Defaults to '23.15.4'.
#
# @param ospd_openvas_version The version for OSP-OpenVAS. Defaults to '22.8.0'.
#
# @param gvm_tools_version The version for GVM tools. Defaults to '25'.
#
# @param feed_release_version The version for feed release. Defaults to '24.10'.
#
# @param data_mount_path The path for data mount. Defaults to '/mnt'.
#
# @param gvm_data_path The path for GVM data. Defaults to '/var/lib/gvm'.
#
# @param openvas_plugins_path The path for OpenVAS plugins. Defaults to '/var/lib/openvas/plugins'.
#
# @param redis_socket_path The path for Redis socket. Defaults to '/run/redis'.
#
# @param gvmd_socket_path The path for GVMD socket. Defaults to '/run/gvmd'.
#
# @param ospd_socket_path The path for OSPD socket. Defaults to '/run/ospd'.
#
# @param psql_data_path The path for PostgreSQL data. Defaults to '/var/lib/postgresql'.
#
# @param psql_socket_path The path for PostgreSQL socket. Defaults to '/var/run/postgresql'.
#
# @param openvas_config_path The path for OpenVAS configuration. Defaults to '/etc/openvas'.
#
# @param openvas_log_path The path for OpenVAS logs. Defaults to '/var/log/openvas'.
#
# @param notus_path The path for Notus. Defaults to '/var/lib/notus'.
#
# @groups installation install_dir, install, storage_path, openvas_config_path, openvas_log_path.
#
# @groups web_interface web_bind_address, web_port.
#
# @groups openvasd openvasd_mode, openvasd_addressport.
#
# @groups version_control vulnerability_tests_version, notus_data_version, scap_data_version, cert_bund_data_version, dfn_cert_data_version, data_objects_version, report_formats_version, gpg_data_version, redis_server_version, pg_gvm_version, gsa_version, gvmd_version, openvas_scanner_version, ospd_openvas_version, gvm_tools_version, feed_release_version.
#
# @groups paths data_mount_path, gvm_data_path, openvas_plugins_path, redis_socket_path, gvmd_socket_path, ospd_socket_path, psql_data_path, psql_socket_path, notus_path.
#
# @groups registry_settings registry.
#
class role::scanner::openvas (
  Stdlib::Absolutepath   $install_dir                  = '/opt/obmondo/docker-compose/openvas',
  Boolean                $install                      = true,
  Stdlib::Host           $web_bind_address             = '127.0.0.1',
  Stdlib::Port           $web_port                     = 9392,
  Enum['service_notus']  $openvasd_mode                = 'service_notus',
  Eit_types::AddressPort $openvasd_addressport         = '0.0.0.0:80',
  Stdlib::Absolutepath   $storage_path                 = '/var/lib/openvas/22.04/vt-data/nasl',
  String                 $registry                     = 'registry.community.greenbone.net/community',
  Eit_types::Version     $vulnerability_tests_version  = '202502250742',
  Eit_types::Version     $notus_data_version           = '202502250410',
  Eit_types::Version     $scap_data_version            = '202502240506',
  Eit_types::Version     $cert_bund_data_version       = '202502250409',
  Eit_types::Version     $dfn_cert_data_version        = '202502250401',
  Eit_types::Version     $data_objects_version         = '202502250505',
  Eit_types::Version     $report_formats_version       = '202502250500',
  Eit_types::Version     $gpg_data_version             = '1.1.0',
  Eit_types::Version     $redis_server_version         = '1.1.0',
  Eit_types::Version     $pg_gvm_version               = '22.6.7',
  Eit_types::Version     $gsa_version                  = '24.3.0',
  Eit_types::Version     $gvmd_version                 = '25',
  Eit_types::Version     $openvas_scanner_version      = '23.15.4',
  Eit_types::Version     $ospd_openvas_version         = '22.8.0',
  Eit_types::Version     $gvm_tools_version            = '25',
  Eit_types::Version     $feed_release_version         = '24.10',
  Stdlib::Absolutepath   $data_mount_path              = '/mnt',
  Stdlib::Absolutepath   $gvm_data_path                = '/var/lib/gvm',
  Stdlib::Absolutepath   $openvas_plugins_path         = '/var/lib/openvas/plugins',
  Stdlib::Absolutepath   $redis_socket_path            = '/run/redis',
  Stdlib::Absolutepath   $gvmd_socket_path             = '/run/gvmd',
  Stdlib::Absolutepath   $ospd_socket_path             = '/run/ospd',
  Stdlib::Absolutepath   $psql_data_path               = '/var/lib/postgresql',
  Stdlib::Absolutepath   $psql_socket_path             = '/var/run/postgresql',
  Stdlib::Absolutepath   $openvas_config_path          = '/etc/openvas',
  Stdlib::Absolutepath   $openvas_log_path             = '/var/log/openvas',
  Stdlib::Absolutepath   $notus_path                   = '/var/lib/notus',
) {
  contain role::virtualization::docker
  contain profile::scanner::openvas
}
