# Define: dmcrypt::key
#
# Generate a key file to be used with dmcrypt
#
# == Name
#   Unused
# == Parameters
# [*key_name*] The name of the key.
#   Mandatory.
#
# [*custom_secret*] A secret to be used in the key.
#   Optional.
#
# == Dependencies
#
# puppet-secret if no custom secret is used
#
# == Authors
#
#  Danny Al-Gaaf <d.al-gaaf@telekom.de>
#
# == Copyright
#
# Copyright 2013 Deutsche Telekom AG
#
define dmcrypt::key (
  $key_name,
  $key_path      = '/root',
  $custom_secret = undef,
) {
  # resources
  $key_file = "${key_path}/${key_name}.key"

  ensure_resource('file', $key_path, {
    ensure => directory,
    mode   => '0500',
    owner  => 'root'
  })

  if $custom_secret {
    file {$key_file:
      ensure  => present,
      mode    => '0600',
      content => "${custom_secret}",
      require => File[$key_path],
    }
  } else {
    $secret = secret($key_name, {
            'length' => 16,
            'method' => 'alphabet'
            })

    $secret_path = "puppet:///secrets/${key_name}"

    file {$key_file:
      ensure  => present,
      mode    => '0600',
      source  => $secret_path,
      require => File[$key_path],
    }
  }
}
