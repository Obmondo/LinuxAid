# @summary Returns validate command for combined PEM files
#
# This command validates that a PEM file contains both a readable certificate
# and a readable private key.
#
# @param openssl_bin Path to openssl binary
#
# @return [String] Shell command suitable for File[...]{ validate_cmd => ... }
function eit_haproxy::pem_validate_cmd(
  String[1] $openssl_bin = '/opt/puppetlabs/puppet/bin/openssl',
) {
  "/bin/sh -c '${openssl_bin} x509 -in % -noout >/dev/null && ${openssl_bin} pkey -in % -noout >/dev/null'"
}
