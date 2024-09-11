#
# == Class: freight::webserver
#
# Integrate a webserver (nginx) with freight
#
class freight::webserver
(
    $document_root,
    $allow_address_ipv4,
    $allow_address_ipv6,

) inherits freight::params
{
    validate_string($document_root)

    class { '::nginx':
        manage               => true,
        manage_config        => true,
        purge_default_config => true,
        allow_address_ipv4   => $allow_address_ipv4,
        allow_address_ipv6   => $allow_address_ipv6,
    }

    # We're only interested in setting up a single server definition, so using 
    # $::fqdn for server_name, log file name, etc. is fine.
    nginx::http_server { 'freight':
        ensure        => 'present',
        server_name   => $::fqdn,
        listen_port   => 80,
        document_root => $document_root,
        autoindex     => 'on',
    }
}
