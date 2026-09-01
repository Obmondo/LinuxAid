# @summary Class for managing the Splunk forwarder in a monitoring setup
#
# @param password_hash The password hash for the forwarder. This parameter is required.
#
# @param version The version of the Splunk forwarder to pin. When left undef (the default),
#   the latest Splunk Universal Forwarder release is tracked automatically instead (checked
#   via `splunk_forwarder_latest_version()`, cached for 6h). Must be set together with
#   `build`, or left undef together with it - setting only one fails the catalog.
#
# @param build The build identifier matching `version`. Only used when `version` is given -
#   ignored (and looked up automatically) when `version` is undef. Must be set together with
#   `version`, or left undef together with it - setting only one fails the catalog.
#
# @param deploymentserver The deployment server URL. Defaults to undef.
#
# @param seed_password Whether to seed the password. Defaults to true.
#
# @param log_keep_count Number of log files to keep. Defaults to 5.
#
# @param log_max_file_size_b Maximum size in bytes for log files. Defaults to 25000000.
#
# @param enable Enable or disable the forwarder. Defaults to false.
#
# @param manage Whether to include the underlying profile to manage the forwarder.
#
# @param noop_value No-operation mode value. Defaults to undef.
#
# @param addons A hash of Splunk add-ons/apps to install via splunk::addon. Keys are add-on
#   names (e.g. 'Splunk_TA_nix') and values are hashes of splunk::addon parameters.
#   Defaults to an empty hash.
#
# @groups settings enable, noop_value
#
# @groups authentication password_hash, seed_password
#
# @groups package_config version, build
#
# @groups connection deploymentserver
#
# @groups logging log_keep_count, log_max_file_size_b
#
# @groups addons addons
#
class common::monitor::splunk::forwarder (
  String[1]                    $password_hash,
  Optional[Eit_types::Version] $version             = undef,
  Optional[String]             $build               = undef,
  Stdlib::HTTPUrl              $deploymentserver    = undef,
  Boolean                      $seed_password       = true,
  Integer                      $log_keep_count      = 5,
  Eit_types::Bytes             $log_max_file_size_b = 25000000,
  Boolean                      $enable              = false,
  Boolean                      $manage              = false,
  Eit_types::Noop_Value        $noop_value          = undef,
  Hash[String[1], Hash]        $addons              = {},
) {

  # Must be pinned together, or the unset one falls back to splunk::params's hardcoded default and mismatches.
  if ($version =~ NotUndef) != ($build =~ NotUndef) {
    fail("common::monitor::splunk::forwarder: version and build must both be set or both be left undef (got version=${version}, build=${build})")
  }

  # Left undef, the function tracks Splunk's latest published release instead of the pin (cached 6h).
  $_latest = splunk_forwarder_latest_version($version, $build)

  if $manage {
    class { 'profile::collector::splunk::forwarder':
      version => $_latest['version'],
      build   => $_latest['build'],
    }
    contain profile::collector::splunk::forwarder
  }
}
