# Microsoft Defender for Endpoint
class common::software::microsoft_mde (
  Boolean                                $manage         = false,
  Boolean                                $enable         = false,
  Optional[Boolean]                      $noop_value     = undef,
  Eit_types::Package::Version::Installed $version        = 'latest',
  Eit_types::Microsoft::Mde::Exclusions  $exclusions     = {},
  # It would be better to use Hiera EYAML for this, but for some reason the
  # base64 encoded contents of the file breaks EYAML, and we end up with a
  # truncated file.
  Optional[Customers::Source]            $onboard_config = undef,
) inherits common {

  confine($enable, !$onboard_config, 'Onboarding config must be provided if enabled.')

  if $manage {
    contain profile::software::microsoft_mde
  }
}
