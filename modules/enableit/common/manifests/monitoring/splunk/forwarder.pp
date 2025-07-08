# @summary Class for managing the Splunk forwarder in a monitoring setup
#
# @param password_hash The password hash for the forwarder. This parameter is required.
#
# @param version The version of the Splunk forwarder. Defaults to '7.2.4'.
#
# @param build The build identifier. Defaults to '8a94541dcfac'.
#
# @param deploymentserver The deployment server URL. Defaults to undef.
#
# @param seed_password Whether to seed the password. Defaults to true.
#
# @param forwarder_output Additional output configuration as a hash. Defaults to an empty hash.
#
# @param log_keep_count Number of log files to keep. Defaults to 5.
#
# @param log_max_file_size_b Maximum size in bytes for log files. Defaults to 25000000.
#
# @param enable Enable or disable the forwarder. Defaults to false.
#
# @param noop_value No-operation mode value. Defaults to undef.
#
class common::monitoring::splunk::forwarder (
  String[1]          $password_hash,
  Eit_types::Version $version             = '7.2.4',
  Optional[String]   $build               = '8a94541dcfac',
  Stdlib::HTTPUrl    $deploymentserver    = undef,
  Boolean            $seed_password       = true,
  Hash               $forwarder_output    = {},
  Integer            $log_keep_count      = 5,
  Eit_types::Bytes   $log_max_file_size_b = 25000000,
  Boolean            $enable              = false,
  Boolean            $noop_value          = undef,
) {
  contain profile::monitoring::splunk::forwarder
}
