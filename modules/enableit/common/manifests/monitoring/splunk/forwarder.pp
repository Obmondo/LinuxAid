# Splunk forwarder
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
