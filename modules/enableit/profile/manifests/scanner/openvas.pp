# @summary Profile for managing the OpenVAS scanner
#
# @param install Whether to install the scanner. Inherited from the role role::scanner::openvas.
#
class profile::scanner::openvas (
  Boolean                $install                      = $role::scanner::openvas::install,
) {
  file { '/opt/obmondo/docker-compose/openvas':
    ensure => ensure_dir($install),
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/opt/obmondo/docker-compose/openvas/docker-compose.yml':
    ensure  => ensure_present($install),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('profile/scanner/openvas/docker-compose.yaml.epp', {
      web_addressport             => '0.0.0.0:9392',
      openvasd_mode               => 'service_notus',
      storage_path                => '/var/lib/openvas/22.04/vt-data/nasl',
      registry                    => 'registry.community.greenbone.net/community',
      vulnerability_tests_version => '202502250742',
      notus_data_version          => '202502250410',
      scap_data_version           => '202502240506',
      cert_bund_data_version      => '202502250409',
      dfn_cert_data_version       => '202502250401',
      data_objects_version        => '202502250505',
      report_formats_version      => '202502250500',
      gpg_data_version            => '1.1.0',
      redis_server_version        => '1.1.0',
      pg_gvm_version              => '22.6.7',
      gsa_version                 => '24.3.0',
      gvmd_version                => '25',
      openvas_scanner_version     => '23.15.4',
      ospd_openvas_version        => '22.8.0',
      gvm_tools_version           => '25',
      feed_release_version        => '24.10',
      data_mount_path             => '/mnt',
      gvm_data_path               => '/var/lib/gvm',
      openvas_plugins_path        => '/var/lib/openvas/plugins',
      redis_socket_path           => '/run/redis',
      gvmd_socket_path            => '/run/gvmd',
      ospd_socket_path            => '/run/ospd',
      psql_data_path              => '/var/lib/postgresql',
      psql_socket_path            => '/var/run/postgresql',
      openvas_config_path         => '/etc/openvas',
      openvas_log_path            => '/var/log/openvas',
      notus_path                  => '/var/lib/notus',
    }),
    require => File['/opt/obmondo/docker-compose/openvas'],
  }

  firewall_multi { '000 allow openvas web interface':
    ensure => ensure_present($install),
    dport  => 443,
    proto  => 'tcp',
    jump   => 'accept',
  }

  docker_compose { 'openvas':
    ensure        => ensure_present($install),
    compose_files => [
      '/opt/obmondo/docker-compose/openvas/docker-compose.yml',
    ],
    require       => File['/opt/obmondo/docker-compose/openvas/docker-compose.yml'],
  }
}
