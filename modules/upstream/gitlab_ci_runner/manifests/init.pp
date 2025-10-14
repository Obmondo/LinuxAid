# @summary This module installs and configures Gitlab CI Runners.
#
# @example Simple runner registration
#		class { 'gitlab_ci_runner':
#		  runners => {
#		 	 example_runner => {
#		 		 'registration-token' => 'gitlab-token',
#		 		 'url'                => 'https://gitlab.com',
#		 		 'tag-list'           => 'docker,aws',
#		 	 },
#		  },
#		}
#
# @param runners
#   Hashkeys are used as $title in runners.pp. The subkeys have to be named as the parameter names from ´gitlab-runner register´ command cause they're later joined to one entire string using 2 hyphen to look like shell command parameters. See ´https://docs.gitlab.com/runner/register/#one-line-registration-command´ for details.
# @param runner_defaults
#   A hash with defaults which will be later merged with $runners.
# @param xz_package_name
#   The name of the 'xz' package. Needed for local docker installations.
# @param concurrent
#   Limits how many jobs globally can be run concurrently. The most upper limit of jobs using all defined runners. 0 does not mean unlimited!
# @param log_level
#   Log level (options: debug, info, warn, error, fatal, panic). Note that this setting has lower priority than level set by command line argument --debug, -l or --log-level
# @param log_format
#   Log format (options: runner, text, json). Note that this setting has lower priority than format set by command line argument --log-format
# @param check_interval
#   Defines the interval length, in seconds, between new jobs check. The default value is 3; if set to 0 or lower, the default value will be used.
# @param shutdown_timeout
#   Number of seconds until the forceful shutdown operation times out and exits the process.
# @param sentry_dsn
#   Enable tracking of all system level errors to sentry.
# @param listen_address
#   Address (<host>:<port>) on which the Prometheus metrics HTTP server should be listening.
# @param session_server
#   Session server lets users interact with jobs, for example, in the interactive web terminal.
# @param manage_docker
#   If docker should be installs (uses the puppetlabs-docker).
# @param install_method
#   If repo or binary should be installed
# @param binary_source
#   URL to the binary file
# @param binary_path
#   Absolute path where to install gitlab_runner binary
# @param manage_user
#   If the user should be managed.
# @param user
#   The user to manage.
# @param group
#   The group to manage.
# @param manage_repo
#   If the repository should be managed.
# @param package_ensure
#   The package 'ensure' state.
# @param package_name
#   The name of the package.
# @param repo_base_url
#   The base repository url.
# @param repo_keyserver
#   The keyserver which should be used to get the repository key.
# @param config_path
#   The path to the config file of Gitlab runner.
# @param config_owner
#   The user owning the config file.
#   (and config directory if managed).
# @param config_group
#   The group ownership assigned to the config file
#   (and config directory if managed).
# @param config_mode
#   The file permissions applied to the config file.
# @param manage_config_dir
#   Manage the parent directory of the config file.
# @param config_dir_mode
#   The file permissions applied to the config directory.
# @param http_proxy
#   An HTTP proxy to use whilst registering runners.
#   This setting is only used when registering or unregistering runners and will be used for all runners in the `runners` parameter.
#   If you have some runners that need to use a proxy and others that don't, leave `runners` and `http_proxy` unset and declare `gitlab_ci_runnner::runner` resources separately.
#   If you do need to use an http proxy, you'll probably also want to configure other aspects of your runners to use it, (eg. setting `http_proxy` environment variables, `pre-clone-script`, `pre-build-script` etc.)
#   Exactly how you might need to configure your runners varies between runner executors and specific use-cases.
#   This module makes no attempt to automatically alter your runner configurations based on the value of this parameter.
#   More information on what you might need to configure can be found [here](https://docs.gitlab.com/runner/configuration/proxy.html)
# @param ca_file
#   A file containing public keys of trusted certificate authorities in PEM format.
#   This setting is only used when registering or unregistering runners and will be used for all runners in the `runners` parameter.
#   It can be used when the certificate of the gitlab server is signed using a CA
#   and when upon registering a runner the following error is shown:
#   `certificate verify failed (self signed certificate in certificate chain)`
#   Using the CA file solves https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/124.
#   The ca_file must exist. If it doesn't, Gitlab runner token generation will be skipped. Gitlab runner will not register until either the file exists or the ca_file parameter is not specified.
# @param repo_keysource URL to the gpg file used to sign the apt packages
#
class gitlab_ci_runner (
  String                                     $xz_package_name, # Defaults in module hieradata
  Hash                                       $runners           = {},
  Hash                                       $runner_defaults   = {},
  Optional[Integer]                          $concurrent        = undef,
  Optional[Gitlab_ci_runner::Log_level]      $log_level         = undef,
  Optional[Gitlab_ci_runner::Log_format]     $log_format        = undef,
  Optional[Integer]                          $check_interval    = undef,
  Optional[Integer]                          $shutdown_timeout  = undef,
  Optional[String]                           $sentry_dsn        = undef,
  Optional[Pattern[/.*:.+/]]                 $listen_address    = undef,
  Optional[Gitlab_ci_runner::Session_server] $session_server    = undef,
  Enum['repo', 'binary']                     $install_method    = 'repo',
  Stdlib::HTTPUrl                            $binary_source     = 'https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest/binaries/gitlab-runner-linux-amd64',
  Stdlib::Absolutepath                       $binary_path       = '/usr/local/bin/gitlab-runner',
  Boolean                                    $manage_user       = false,
  String[1]                                  $user              = 'gitlab-runner',
  String[1]                                  $group             = $user,
  Boolean                                    $manage_docker     = false,
  Boolean                                    $manage_repo       = true,
  String                                     $package_ensure    = installed,
  String                                     $package_name      = 'gitlab-runner',
  Stdlib::HTTPUrl                            $repo_base_url     = 'https://packages.gitlab.com',
  Optional[Gitlab_ci_runner::Keyserver]      $repo_keyserver    = undef,
  String                                     $config_path       = '/etc/gitlab-runner/config.toml',
  String[1]                                  $config_owner      = 'root',
  String[1]                                  $config_group      = 'root',
  Stdlib::Filemode                           $config_mode       = '0444',
  Boolean                                    $manage_config_dir = false,
  Optional[Stdlib::Filemode]                 $config_dir_mode   = undef,
  Optional[Stdlib::HTTPUrl]                  $http_proxy        = undef,
  Optional[Stdlib::Unixpath]                 $ca_file           = undef,
  Stdlib::HTTPSUrl                           $repo_keysource    = "${repo_base_url}/gpg.key",
  Optional[Stdlib::HTTPSUrl]                 $package_keysource = undef,
  Boolean                                    $package_gpgcheck  = true,
) {
  if $manage_docker {
    # workaround for cirunner issue #1617
    # https://gitlab.com/gitlab-org/gitlab-ci-multi-runner/issues/1617
    stdlib::ensure_packages($xz_package_name)

    $docker_images = {
      ubuntu_focal => {
        image     => 'ubuntu',
        image_tag => 'focal',
      },
    }

    include docker
    class { 'docker::images':
      images => $docker_images,
    }
  }

  if $manage_repo {
    contain gitlab_ci_runner::repo
  }

  contain gitlab_ci_runner::install
  contain gitlab_ci_runner::config
  contain gitlab_ci_runner::service

  Class['gitlab_ci_runner::install']
  -> Class['gitlab_ci_runner::config']
  ~> Class['gitlab_ci_runner::service']

  $runners.each |$runner_name,$config| {
    $_config = $runner_defaults + $config
    $title   = $_config['name'] ? {
      undef   => $runner_name,
      default => $_config['name'],
    }
    $_ca_file = $_config['ca_file'] ? {
      undef   => $ca_file,
      default => $_config['ca_file'],
    }

    gitlab_ci_runner::runner { $title:
      ensure     => $_config['ensure'],
      config     => $_config - ['ensure', 'name', 'ca_file'],
      http_proxy => $http_proxy,
      ca_file    => $_ca_file,
      require    => Class['gitlab_ci_runner::config'],
      notify     => Class['gitlab_ci_runner::service'],
    }
  }
}
