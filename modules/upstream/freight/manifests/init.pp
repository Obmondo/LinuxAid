#
# == Class: freight
#
# Manage freight (apt) repositories.
#
# == Parameters
#
# [*manage*]
#   Whether to manage freight with Puppet or not. Valid values are true 
#   (default) and false.
# [*manage_webserver*]
#   Whether to manage the webserver (nginx) or not. Valid values are true 
#   (default) and false. If you set this to false, make sure that a webserver is 
#   configured and that the parent directory of $varcache directory exists 
#   before this class is included.
# [*allow_address_ipv4*]
#   IPv4 addresses/networks from which to allow connections. This parameter can
#   be either a string or an array. Defaults to 'anyv4' which means that access
#   is allowed from any IPv4 address. Uses the webserver module to do the hard
#   lifting. This parameter has no effect if $manage_webserver is false.
# [*allow_address_ipv6*]
#   As above but for IPv6 addresses. Defaults to 'anyv6', thus allowing access 
#   from any IPv6 address. This parameter has no effect if $manage_webserver is 
#   false.
# [*document_root*]
#   The document root for the webserver. This parameter is ignored unless you've 
#   set $manage_webserver to true. Defaults to '/var/www'.
# [*default_gpg_key_id*]
#   The GPG key ID to use unless something else if defined by the 
#   freight::config instance.
# [*default_gpg_key_email*]
#   The GPG key email to use unless something else if defined by the 
#   freight::config instance.
# [*default_gpg_key_passphrase*]
#   The GPG key passphrase to use unless something else if defined by the 
#   freight::config instance.
# [*configs*]
#   A hash of freight::config resources to realize. You need to define at least 
#   one.
#
# == Authors
#
# Samuli Seppänen <samuli.seppanen@gmail.com>
#
# Samuli Seppänen <samuli@openvpn.net>
#
# == License
#
# BSD-license. See file LICENSE for details.
#
class freight
(
    $default_gpg_key_id = undef,
    $default_gpg_key_email = undef,
    $allow_address_ipv4 = 'anyv4',
    $allow_address_ipv6 = 'anyv6',
    $document_root = '/var/www',
    $default_gpg_key_passphrase=undef,
    $manage = true,
    $manage_webserver = true,
    $configs = {}
)
{

# Validate parameters
validate_bool($manage)
validate_bool($manage_webserver)

if $manage {

    if $manage_webserver {
        class { '::freight::webserver':
            document_root      => $document_root,
            allow_address_ipv4 => $allow_address_ipv4,
            allow_address_ipv6 => $allow_address_ipv6,
        }
    }
    include ::freight::aptrepo
    include ::freight::install

    # Create one or more freight instances. While an overkill for a single 
    # repository, this is required when hosting several unrelated repositories 
    # on the same host.
    $defaults = { 'manage_webserver' => $manage_webserver }

    create_resources('freight::config', $configs, $defaults)

}
}
