# NFS service class
class nfs::server::services (
  Array[String] $services,
  Enum['running', 'stopped'] $ensure = running,
  Boolean $enable                    = true,
  Boolean $configonly                = false,
) {

  require portmap

  if !$configonly {
    service { $services:
      ensure     => $ensure,
      enable     => $enable,
      hasstatus  => true,
      hasrestart => true,
    }
  }
}
