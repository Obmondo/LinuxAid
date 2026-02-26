# @summary Role for managing the OpenVAS scanner
#
# @param install Whether to install the scanner. Defaults to true.
#
# @param expose Whether to expose the scanner to the network. Defaults to true.
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
  Boolean                $install                      = true,
  Boolean                $expose                       = true,
) {
  contain role::virtualization::docker

  if $expose {
    contain role::web::haproxy
  }

  contain profile::scanner::openvas
}
