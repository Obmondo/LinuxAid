# @summary Class for managing Microsoft Defender for Endpoint installation and configuration
#
# @param manage Whether to manage the Microsoft Defender for Endpoint installation. Defaults to false.
#
# @param enable Whether to enable Microsoft Defender for Endpoint. Defaults to false.
#
# @param noop_value Optional value for noop mode. Defaults to undef.
#
# @param version The installed version of Microsoft Defender for Endpoint. Defaults to 'latest'.
#
# @param exclusions Exclusions configuration for Microsoft Defender for Endpoint. Defaults to an empty hash.
#
# @param onboard_config Optional onboard configuration source. Defaults to undef.
#
# @groups management manage, enable.
#
# @groups configuration noop_value, version, exclusions, onboard_config.
#
class common::software::microsoft_mde (
  Boolean                                $manage         = false,
  Boolean                                $enable         = false,
  Eit_types::Noop_Value                  $noop_value     = undef,
  Eit_types::Package::Version::Installed $version        = 'latest',
  Eit_types::Microsoft::Mde::Exclusions  $exclusions     = {},
  # It would be better to use Hiera EYAML for this, but for some reason the
  # base64 encoded contents of the file breaks EYAML, and we end up with a
  # truncated file.
  Optional[Eit_Files::Source]            $onboard_config = undef,
) inherits common {
  confine($enable, !$onboard_config, 'Onboarding config must be provided if enabled.')
  if $manage {
    contain profile::software::microsoft_mde
  }
}
