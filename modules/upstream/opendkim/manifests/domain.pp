define opendkim::domain (
    $domain        = $name,
    $selector      = $hostname,
    $pathkeys      = '/etc/opendkim/keys',
    $keytable      = 'KeyTable',
    $signing_table = 'SigningTable',
) {
    # $pathConf and $pathKeys must be without trailing '/'.
    # For example, '/etc/opendkim/keys'

    Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

    # Create directory for domain
    file { "${pathkeys}/${domain}":
        ensure  => directory,
        owner   => $opendkim::owner,
        group   => $opendkim::group,
        mode    => '0755',
        notify  => Service[$opendkim::service_name],
        require => Package[$opendkim::package_name],
    }

    # Generate dkim-keys
    exec { "opendkim-genkey -D ${pathkeys}/${domain}/ -d ${domain} -s ${selector}":
        unless  => "/usr/bin/test -f ${pathkeys}/${domain}/${selector}.private && /usr/bin/test -f ${pathkeys}/${domain}/${selector}.txt",
        user    => $opendkim::owner,
        notify  => Service[$opendkim::service_name],
        require => [ Package[$opendkim::package_name], File["${pathkeys}/${domain}"], ],
    }

    # Add line into KeyTable
    file_line { "${opendkim::pathconf}/${keytable}_${domain}":
        path    => "${opendkim::pathconf}/${keytable}",
        line    => "${selector}._domainkey.${domain} ${domain}:${selector}:${pathkeys}/${domain}/${selector}.private",
        notify  => Service[$opendkim::service_name],
        require => Package[$opendkim::package_name],
    }

    # Add line into SigningTable
    file_line { "${opendkim::pathconf}/${signing_table}_${domain}":
        path    => "${opendkim::pathconf}/${signing_table}",
        line    => "*@${domain} ${selector}._domainkey.${domain}",
        notify  => Service[$opendkim::service_name],
        require => Package[$opendkim::package_name],
    }
}
