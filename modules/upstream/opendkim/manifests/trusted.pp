define opendkim::trusted (
    $host          = $name,
    $trusted_hosts = 'TrustedHosts',
    
) {
    # Add line into KeyTable
    file_line { "${opendkim::pathconf}/${trusted_hosts}_${host}":
        path    => "${opendkim::pathconf}/${trusted_hosts}",
        line    => $host,
        notify  => Service[$opendkim::service_name],
        require => Package[$opendkim::package_name],
    }
}
