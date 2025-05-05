# @summary This configures a Gitlab CI runner.
#
# @example Add a simple runner
#   gitlab_ci_runner::runner { 'testrunner':
#     config               => {
#       'url'              => 'https://gitlab.com',
#       'token'            => '123456789abcdefgh', # Note this is different from the registration token used by `gitlab-runner register`
#       'executor'         => 'shell',
#     },
#   }
#
# @example Add a autoscaling runner with DigitalOcean as IaaS
#   gitlab_ci_runner::runner { 'autoscale-runner':
#     config => {
#       url      => 'https://gitlab.com',
#       token    => 'RUNNER_TOKEN', # Note this is different from the registration token used by `gitlab-runner register`
#       name     => 'autoscale-runner',
#       executor => 'docker+machine',
#       limit    => 10,
#       docker   => {
#         image => 'ruby:2.6',
#       },
#       machine  => {
#         OffPeakPeriods   => [
#           '* * 0-9,18-23 * * mon-fri *',
#           '* * * * * sat,sun *',
#         ],
#         OffPeakIdleCount => 1,
#         OffPeakIdleTime  => 1200,
#         IdleCount        => 5,
#         IdleTime         => 600,
#         MaxBuilds        => 100,
#         MachineName      => 'auto-scale-%s',
#         MachineDriver    => 'digitalocean',
#         MachineOptions   => [
#           'digitalocean-image=coreos-stable',
#           'digitalocean-ssh-user=core',
#           'digitalocean-access-token=DO_ACCESS_TOKEN',
#           'digitalocean-region=nyc2',
#           'digitalocean-size=4gb',
#           'digitalocean-private-networking',
#           'engine-registry-mirror=http://10.11.12.13:12345',
#         ],
#       },
#       cache    => {
#         'Type' => 's3',
#         s3     => {
#           ServerAddress => 's3-eu-west-1.amazonaws.com',
#           AccessKey     => 'AMAZON_S3_ACCESS_KEY',
#           SecretKey     => 'AMAZON_S3_SECRET_KEY',
#           BucketName    => 'runner',
#           Insecure      => false,
#         },
#       },
#     },
#   }
#
# @param config
#   Hash with configuration options.
#   See https://docs.gitlab.com/runner/configuration/advanced-configuration.html for all possible options.
#   If you omit the 'name' configuration, we will automatically use the $title of this define class.
#
# @param ensure
#   If the runner should be 'present' or 'absent'.
#   Will add/remove the configuration from config.toml
#   Will also register/unregister the runner.
#
# @param ca_file
#   A path to a file containing public keys of trusted certificate authorities in PEM format.
#   Used during runner registration/unregistration only.
#
define gitlab_ci_runner::runner (
  Hash $config,
  Enum['present', 'absent']  $ensure     = 'present',
  Optional[Stdlib::HTTPUrl]  $http_proxy = undef,
  Optional[Stdlib::Unixpath] $ca_file    = undef,
) {
  include gitlab_ci_runner

  $config_path       = $gitlab_ci_runner::config_path
  # Use title parameter if config hash doesn't contain one.
  $_config     = $config['name'] ? {
    undef   => $config + { name => $title },
    default => $config,
  }

  if $_config['registration-token'] {
    $register_additional_options = $config
    .filter |$item| { $item[0] =~ Gitlab_ci_runner::Register_parameters } # Get all items use for the registration process
    .reduce({}) |$memo, $item| { $memo + { regsubst($item[0], '-', '_', 'G') => $item[1] } } # Ensure all keys use '_' instead of '-'

    $deferred_call = Deferred('gitlab_ci_runner::register_to_file', [$_config['url'], $_config['registration-token'], $_config['name'], $register_additional_options, $http_proxy, $ca_file])

    # Remove registration-token and add a 'token' key to the config with a Deferred function to get it.
    $__config = ($_config - (Array(Gitlab_ci_runner::Register_parameters) + 'registration-token')) + { 'token' => $deferred_call }
  } else {
    # Fail if the user supplied configuration options which are meant for the registration, but not for the config file
    $_config.keys.each |$key| {
      if $key in Array(Gitlab_ci_runner::Register_parameters) {
        fail("\$config contains a configuration key (${key}) which is meant for the registration, but not for the config file. Please remove it or add a 'registration-token'!")
      }
    }

    $__config = $_config
  }

  $content = $__config['token'] =~ Deferred ? {
    true  => Deferred('gitlab_ci_runner::to_toml', [{ runners => [$__config], }]),
    false => gitlab_ci_runner::to_toml({ runners => [$__config], }),
  }

  if $ensure == 'present' {
    concat::fragment { "${config_path} - ${title}":
      target  => $config_path,
      order   => 2,
      content => $content,
    }
  } else {
    $absent_content = Deferred('gitlab_ci_runner::unregister_from_file', [$_config['url'], $_config['name'], $http_proxy, $ca_file])

    file { "/etc/gitlab-runner/auth-token-${_config['name']}":
      ensure  => absent,
      content => $absent_content, # This line might look pointless, but isn't.  The Deferred must appear in the catalog if we actually want it to run.
    }
  }
}
