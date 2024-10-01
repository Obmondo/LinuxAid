# Mirror
# debmirror package does not handle `cnf` directories
# work around is to get the debmirror package from 21.10 ubuntu
# http://launchpadlibrarian.net/541793181/debmirror_2.34ubuntu1_all.deb
class repository::mirror (
  Boolean                          $enable,
  Boolean                          $snapshot,
  Eit_types::SystemdTimer::Weekday $weekday,
  Eit_types::User                  $user,
  Stdlib::Unixpath                 $basedir,
  Stdlib::AbsolutePath             $config_dir      = '/etc/obmondo/repository-mirror',
  Stdlib::AbsolutePath             $repo_config_dir = "${config_dir}/repos",

  Repository::Mirrors::Configurations          $configurations  = {},
  Eit_types::URL                               $key_server      = 'hkps://keyserver.ubuntu.com',
  Variant[Stdlib::AbsolutePath, Pattern[/^~/]] $keyring_file    = '~/.gnupg/trustedkeys.kbx',
) {

  include repository::package
  include repository::snapshot

  # Lets have the script and the script directory present incase customer leaves
  # Obmondo
  file { [
    $config_dir,
    $repo_config_dir,
  ]:
    ensure  => directory,
    owner   => $user,
    group   => $user,
    purge   => true,
    recurse => true,
  }

  package { 'obmondo-repository-mirror':
    ensure => ensure_latest($enable),
  }

  $configurations.map |$_repo_name, $_repo_config| {
    $_repo_config.map |$_provider, $_supported_dist| {
      $_supported_dist.map |$_dist, $_configs| {
        if type($_configs) =~ Type[Hash] {
          { 'repo_name' => $_repo_name,
            'provider' => $_provider,
            'repodir' => $_configs['repodir']
          }
        }
      }
    }.flatten.delete_undef_values
  }.flatten.group_by |$_entry| {
    $_entry['repodir']
  }.each |$repodir, $entries| {
    $providers = $entries.map |$entry| { $entry['provider'] }.unique
    $repo_names = $entries.map |$entry| { $entry['repo_name'] }.unique

    if $providers.size > 1 or $repo_names.size > 1 {
      fail("Conflicting repodir: ${repodir}. Providers: ${providers.join(', ')}. Repo Names: ${repo_names.join(', ')}")
    }
  }

  $configurations.each |$_repo_name, $_repo_config| {
    $_repo_config.each |$_provider, $_supported_dist| {
      if ! $_supported_dist['enable'] {
        next()
      }

      $_any_enabled_repos = $_supported_dist.map |$_dist, $_configs| {
        if type($_configs) =~ Type[Hash] {
          $_configs['enable']
        }
      }.delete_undef_values

      $_supported_dist.each |$_dist, $_configs| {

        if type($_configs) =~ Type[Hash] {
          if (true in $_any_enabled_repos) {
            if $_configs['enable'] {
              repository::mirror::repo {
                default:
                  * => $_configs,
                ;
                "${_repo_name}_${_provider}_${_dist}":
                  identifier => $_repo_name,
                ;
              }
            }
          } else {
            if $_supported_dist['enable'] and ! $_configs['enable'] {
              $_enabled_repos = $_configs + { enable => $_supported_dist['enable'] }
              repository::mirror::repo {
                default:
                  * => $_configs
                ;
                "${_repo_name}_${_provider}_${_dist}":
                  identifier => $_repo_name,
                  enable     => $_supported_dist['enable']
                ;
              }
            }
          }
        }
      }
    }
  }
}
