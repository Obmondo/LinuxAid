class docker_distribution::install {
  if $::docker_distribution::manage_as == 'container' {
    if $::docker_distribution::http_tls_certificate {
      $vol_cert = "${::docker_distribution::http_tls_certificate}:${::docker_distribution::http_tls_certificate}"
    } else {
      $vol_cert = undef
    }

    if $::docker_distribution::http_tls_key {
      $vol_key = "${::docker_distribution::http_tls_key}:${::docker_distribution::http_tls_key}"
    } else {
      $vol_key = undef
    }

    if $::docker_distribution::http_tls_clientcas {
      $vol_ca = "${::docker_distribution::http_tls_clientcas}:${::docker_distribution::http_tls_clientcas}"
    } else {
      $vol_ca = undef
    }

    if $::docker_distribution::mount_global_ca {
      $vol_global_ca = "${::docker_distribution::global_ca}:/etc/ssl/certs/ca-certificates.crt"
    } else {
      $vol_global_ca = undef
    }

    docker::run { $::docker_distribution::package_name:
      image           => $::docker_distribution::container_image,
      volumes         => delete_undef_values([
          "${::docker_distribution::config_file}:/etc/docker/registry/config.yml",
          "${::docker_distribution::filesystem_rootdirectory}:${::docker_distribution::filesystem_rootdirectory}",
          "${::docker_distribution::auth_token_rootcertbundle}:${::docker_distribution::auth_token_rootcertbundle}",
          $vol_global_ca,
          $vol_cert,
          $vol_key,
          $vol_ca,
      ]),
      restart_service => true,
      net             => 'host',
      detach          => false,
      manage_service  => true,
      running         => true,
    }
  } else {
    package { [$::docker_distribution::package_name]: ensure => $::docker_distribution::package_ensure, }
  }
}
