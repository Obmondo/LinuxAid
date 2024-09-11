# A class to install and manage Yum configuration.
#
# @param clean_old_kernels
#   Whether or not to purge old kernel version beyond the `keeponly_limit`.
#
# @param keep_kernel_devel
#   Whether or not to keep kernel devel packages on old kernel purge.
#
# @param config_options
#   A Hash where keys are the names of `Yum::Config` resources and the values
#   are either the direct `ensure` value, or a Hash of the resource's attributes.
#
#   @note Boolean parameter values will be converted to either a `1` or `0`; use a quoted string to
#     get a literal `true` or `false`. Sensitive value will disable the `show_diff`.
#
#
# @param repos
#   A hash where keys are the names of `Yumrepo` resources and each value represents its respective
#   Yumrepo's resource parameters.  This is used in conjunction with the `managed_repos` parameter
#   to create `Yumrepo` resources en masse.  Some default data is provided for this using module
#   data.  It is configured to deep merge with a `knockout_prefix` of `--` by default, so individual
#   parameters may be overriden or removed via global or environment Hiera data.
#
#   @note Boolean parameter values will be converted to either a `1` or `0`; use a quoted string to
#     get a literal `true` or `false`.
#
# @param managed_repos
#   An array of first-level keys from the `repos` hash to include in the catalog.  The module uses
#   this list to select `Yumrepo` resources from the `repos` hash for instantiation.  Defaults are
#   set in the module's Hiera data.
#
#   @note This only indicates the *managed* state of the repos, the `ensure` state must be managed
#     in the `repos` data.
#
# @param manage_os_default_repos
#   Whether or not to add an operating system's default repos to the `managed_repos` array.
#
#   @note This only works for operating systems with data in the module's data directory.  Currently
#     the module only contains data for for CentOS 6 & 7.
#
# @param os_default_repos
#   A list of default repos to add to `managed_repos` if `manage_os_default_repos` is enabled.
#   Normally this should not be modified.
#
# @param repo_exclusions
#   An array of first-level keys from the `repos` hash to exclude from management via this module.
#   Values in this array will be subtracted from the `managed_repos` array as a last step before
#   instantiation.
#
# @param gpgkeys
#   A hash of yum::gpgkey types, which will be automatically included if they
#   are referenced by a managed_repo. This will use the same merging behavior
#   as repos.
#
# @param utils_package_name
#   Name of the utils package, e.g. 'yum-utils', or 'dnf-utils'.
#
# @param groups
#   A hash of yum::group instances to manage.
#
# @example Enable management of the default repos for a supported OS:
#   ---
#   yum::manage_os_default_repos: true
#
# @example Add Hiera data to disable *management* of the CentOS Base repo:
#   ---
#   yum::manage_os_default_repos: true
#   yum::repo_exclusions:
#       - 'base'
#
# @example Ensure the CentOS base repo is removed from the agent system(s):
#   ---
#   yum::manage_os_default_repos: true
#   yum::repos:
#       base:
#           ensure: 'absent'
#
# @example Add a custom repo:
#   ---
#   yum::managed_repos:
#       - 'example_repo'
#   yum::repos:
#       example_repo:
#           ensure: 'present'
#           enabled: true
#           descr: 'Example Repo'
#           baseurl: 'https://repos.example.com/example/'
#           gpgcheck: true
#           gpgkey: 'file:///etc/pki/gpm-gpg/RPM-GPG-KEY-Example'
#           target: '/etc/yum.repos.d/example.repo'
#
# @example Use a custom `baseurl` for the CentOS Base repo:
#   ---
#   yum::manage_os_default_repos: true
#   yum::repos:
#       base:
#           baseurl: 'https://repos.example.com/CentOS/base/'
#           mirrorlist: '--'
#
# @example Install a couple of `yum::group`s.
#   ---
#   yum::groups:
#     'Development Tools':
#       ensure: present
#     'System Tools':
#       ensure: present
#
class yum (
  Boolean $clean_old_kernels = true,
  Boolean $keep_kernel_devel = false,
  Hash[String, Variant[String, Integer, Boolean, Sensitive[String], Hash[String, Variant[String, Integer, Boolean, Sensitive[String]]]]] $config_options = {},
  Hash[String, Optional[Hash[String, Variant[String, Integer, Boolean]]]] $repos = {},
  Array[String] $managed_repos = [],
  Boolean $manage_os_default_repos = false,
  Array[String] $os_default_repos = [],
  Array[String] $repo_exclusions = [],
  Hash[String, Hash[String, String]] $gpgkeys = {},
  String $utils_package_name = 'yum-utils',
  Stdlib::CreateResources $groups = {}
) {
  $module_metadata            = load_module_metadata($module_name)
  $supported_operatingsystems = $module_metadata['operatingsystem_support']
  $supported_os_names         = $supported_operatingsystems.map |$os| {
    $os['operatingsystem']
  }

  unless member($supported_os_names, $facts['os']['name']) {
    fail("${facts['os']['name']} not supported")
  }

  $_managed_repos = $manage_os_default_repos ? {
    true    => $managed_repos + $os_default_repos,
    default => $managed_repos,
  }

  unless empty($_managed_repos) or empty($repos) {
    $_managed_repos_minus_exclusions = $_managed_repos - $repo_exclusions
    $normalized_repos = yum::bool2num_hash_recursive($repos)

    $normalized_repos.each |$yumrepo, $attributes| {
      if member($_managed_repos_minus_exclusions, $yumrepo) {
        yumrepo { $yumrepo:
          * => $attributes,
        }
        # Handle GPG Key
        if ('gpgkey' in $attributes) {
          $matches = $attributes['gpgkey'].split(/\s/).match('^file://(.*)$')
          $matches.each |$match| {
            if $match {
              $gpgkey = $match[1]
              if $gpgkey =~ Stdlib::AbsolutePath and $gpgkey in $gpgkeys {
                if !defined(Yum::Gpgkey[$gpgkey]) {
                  yum::gpgkey { $gpgkey:
                    *      => $gpgkeys[$gpgkey],
                    before => Package[$utils_package_name],
                    # GPG Keys for any managed repository need to be installed before we attempt to install any packages.
                  }
                } # end if Yum::Gpgkey[$gpgkey] is not defined
              } # end if $gpgkey exists in gpgkeys
            } # end if gpgkey is a file:// resource
          } # end each matches
        } # end if $attributes has a gpgkey
      }
    }
  }

  unless empty($config_options) {
    if ('installonly_limit' in $config_options) {
      assert_type(Variant[Integer, Hash[String, Integer]], $config_options['installonly_limit']) |$expected, $actual| {
        fail("The value or ensure for `\$yum::config_options[installonly_limit]` must be an Integer, but it is not.")
      }
    }

    $_normalized_config_options = $config_options.map |$key, $attrs| {
      $_ensure = $attrs ? {
        Hash    => $attrs[ensure],
        default => $attrs,
      }

      $_normalized_ensure = $_ensure ? {
        Boolean => Hash({ 'ensure' => bool2num($_ensure) }),
        default => Hash({ ensure => $_ensure }), # lint:ignore:unquoted_string_in_selector
      }

      $_normalized_attrs = $attrs ? {
        Hash    => $attrs + $_normalized_ensure,
        default => $_normalized_ensure,
      }

      Hash({ $key => $_normalized_attrs })
    }.reduce |$memo, $cfg_opt_hash| {
      $memo + $cfg_opt_hash
    }

    $_normalized_config_options.each |$config, $attributes| {
      yum::config { $config:
        * => $attributes,
      }
    }
  }

  unless defined(Yum::Config['installonly_limit']) {
    yum::config { 'installonly_limit': ensure => '3' }
  }

  $_clean_old_kernels_subscribe = $clean_old_kernels ? {
    true    => Yum::Config['installonly_limit'],
    default => undef,
  }

  # cleanup old kernels
  stdlib::ensure_packages([$utils_package_name])

  $_real_installonly_limit = $config_options['installonly_limit'] ? {
    Variant[String, Integer] => $config_options['installonly_limit'],
    Hash                     => $config_options['installonly_limit']['ensure'],
    default                  => '3',
  }

  $_keep_kernel_devel = $keep_kernel_devel ? {
    true    => $facts['package_provider'] ? {
      'yum'   => '--keepdevel ',
      'dnf'   => '--exclude kernel-release',
      default => fail("Fact package_provider is not set to \'yum\' or \'dnf\' - giving up"),
    },
    default => '',
  }

  $_pc_cmd = $facts['package_provider'] ? {
    'yum'   => "/usr/bin/package-cleanup --oldkernels --count=${_real_installonly_limit} -y${$_keep_kernel_devel}",
    default => "/usr/bin/dnf -y remove $(/usr/bin/dnf repoquery --installonly --latest-limit=-${_real_installonly_limit}${_keep_kernel_devel} | /usr/bin/grep -v ${facts['kernelrelease']})"
  }

  exec { 'package-cleanup_oldkernels':
    command     => $_pc_cmd,
    refreshonly => true,
    require     => Package[$utils_package_name],
    subscribe   => $_clean_old_kernels_subscribe,
  }

  $groups.each |$_group, $_group_attrs| {
    yum::group { $_group:
      * => $_group_attrs,
    }
  }
}
