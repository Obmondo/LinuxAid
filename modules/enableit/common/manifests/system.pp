# @summary Class for managing common system configuration
#
# @param remove_fstrim_cron Boolean indicating whether to remove the fstrim cron job. Defaults to false.
#
# @param purge_root_ssh_keys Boolean indicating whether to purge SSH keys for the root user. Defaults to true.
#
# @param ssh_authorized_keys Hash of SSH authorized keys with parameters such as 'key', 'user', 'options', 'noop_value'. Defaults to {}.
#
# @param users Hash of user resources, keyed by username, with user parameters. Defaults to {}.
#
# @param user_groups Hash mapping usernames to array of groups they should belong to. Defaults to {}.
#
# @param groups Hash of group resources with parameters. Defaults to {}.
#
# @param services Hash of service configurations. Defaults to {}.
#
# @param files Hash of file resources with parameters. Defaults to {}.
#
# @param disable_ipv6 Optional Boolean to disable IPv6. Defaults to undef.
#
# @param service_oneshot Optional Hash mapping service names to their content for one-shot services. Defaults to {}.
#
# @param locations Hash mapping location names to arrays of IP addresses or IP ranges for location detection. Defaults to {}.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @groups service_config services, service_oneshot
#
# @groups user_management users, user_groups, ssh_authorized_keys, purge_root_ssh_keys
#
# @groups system_config remove_fstrim_cron, disable_ipv6
#
# @groups network_config locations
#
# @groups file_management files
#
# @groups group_management groups
#
class common::system (
  Boolean $remove_fstrim_cron = false,
  Boolean $purge_root_ssh_keys = true,
  Eit_types::Ssh_authorized_keys $ssh_authorized_keys = {},
  Eit_types::Users               $users               = {},
  Hash[String,Array[String]]     $user_groups         = {},
  Hash[String,Hash]              $groups              = {},
  Hash[String, Hash]             $services            = {},
  Hash[String,Hash]              $files               = {},
  Optional[Boolean]              $disable_ipv6        = undef,
  Optional[Hash[String, Struct[{
          content => Stdlib::Base64,
  }]]] $service_oneshot  = undef,

  Hash[String, Array[Stdlib::IP::Address::V4]] $locations = {},
  Eit_types::Encrypt::Params    $encrypt_params           = ['ssh_authorized_keys.*.key'],
) {
  ############
  # Services #
  ############

  $services.each |$_service_name, $_config| {
    service { $_service_name:
      * => $_config,
    }
  }

  ###########
  # SSH
  ###########

  $ssh_authorized_keys.map |$name, $v| {
    # An SSH pubkey is at least 64 chars long, hence the regex
    $_ssh_key_match = $v['key'].match(/((?<type>.*) )(?<key>AAAA[^ ]{64,})( (?<comment>.*+))?/)

    $home_dir_path = $v['user'] ? {
      'root'          => '/root',
      'obmondo-admin' => "/opt/obmondo/home/${v['user']}",
      default         => "/home/${v['user']}",
    }

    ssh_authorized_key { $name:
      name    => pick($_ssh_key_match[3], $name),
      user    => $v['user'],
      type    => $_ssh_key_match[1],
      key     => $_ssh_key_match[2],
      noop    => $v['noop_value'],
      options => $v['options'],
      target  => "${home_dir_path}/.ssh/authorized_keys",
    }
  }

  ##############
  # SYSTEMD
  ##############

  if $facts['init_system'] == 'systemd' {
    include common::system::systemd
  }

  if $remove_fstrim_cron or $facts['virtual'] == 'lxc' {
    # Remove the fstrim cron job. This comes from the `util-linux` and is
    # installed by default with no proper way to disable it. Issues at
    # https://github.com/lxc/lxd/issues/2030 and
    # https://bugs.launchpad.net/ubuntu/+source/util-linux/+bug/1589289 .
    file { '/etc/cron.weekly/fstrim':
      ensure => absent,
    }
  }

  ##############
  # USERS
  ##############

  # We do this to support purging SSH keys from the root user, regardless of if
  # the user is managed or not. If $users contains `root` and
  # `$purge_root_ssh_keys` we inject (and override) `purge_ssh_keys` in the
  # `root` resource.
  $_users = if 'root' in $users and $purge_root_ssh_keys {
    $users + {
      'root' => $users['root'] + {
        home           => '/root',
        purge_ssh_keys => true,
      }
    }
  } else {
    $users
  }

  create_resources('eit_users::user', $_users)

  # If $users doesn't contain `root` we simply manage the user
  if $purge_root_ssh_keys and !('root' in $users) {
    user { 'root':
      ensure         => 'present',
      home           => '/root',
      purge_ssh_keys => true,
    }
  }

  $groups.each |$key, $value| {
    group { $key :
      * => $value,
    }
  }

  # Manage user group membership in local groups. This is handy e.g. for adding
  # AD users to a local 'docker' group.
  $user_groups.each |$_user, $_groups| {
    $_groups.each |$_group| {
      exec { "usermod -aG '${_group}' '${_user}'":
        # This is a bit long, but it pulls the list of members of a local group,
        # outputs the members prefixed and suffixed with comma and greps for the
        # group name surrounded by commas. This way it will work even if the
        # user is the first or last in the list of members (because we add the
        # commas).
        onlyif => "getent -s files group '${_group}' | awk '{ printf \",%s,\", \$NF}' FS=: | grep -vq ',${_user},'",
        path   => [
          '/sbin',
          '/usr/sbin',
          '/bin',
          '/usr/bin',
        ],
      }
    }
  }

  ##############
  # FILES
  ##############

  # Special Obmondo file resource pattern. Will be translated into a file in the
  # ::customers module (e.g. `obmondo:///some_file.txt` =>
  # `puppet:///modules/customers/files/$customer_id/some_file.txt`)

  # sort the files to ensure that directores always come before files
  Array($files.functions::knockout).sort |$x, $y| {
    compare($x[0], $y[0])
  }.each |$_element| {
    [$key, $_file_parameters] = $_element
    $_source = $_file_parameters['source']
    # Only allow sources that the Obmondo file resource pattern
    if $_source and $_source !~ Eit_Files::Source {
    fail("Invalid file resource
           ${_element}")
    }

    eit_files::file { $key:
      * => $_file_parameters,
    }
  }

  ##################
  #  Service_Oneshot
  #################

  $service_oneshot.lest || {{} }.each |$name, $value| {
    profile::system::service_oneshot { $name:
      content => $value['content'],
    }
  }

  #############
  # NETWORK
  #############

  if $disable_ipv6 =~ Boolean {
    sysctl::configuration { 'net.ipv6.conf.all.disable_ipv6':
      value => $disable_ipv6,
    }
  }

  ############
  # LOCATION #
  ############

  $_location = $locations.map |$location, $ip_address| {
    $ip_address.map |$ip_addr| {
      if $ip_addr == $facts['networking']['ip'] {
        $location
      } elsif stdlib::ip_in_range($facts['networking']['ip'], $ip_addr) {
        $location
      }
    }
  }.flatten.join('')

  $_puppet_dir = $facts['puppet_confdir'].dirname

  $_obmondo_system_facts = {
    'obmondo_system' => {
      'location' => $_location,
      'certname' => $trusted['certname'],
    },
  }

  file { "${_puppet_dir}/facter/facts.d/obmondo_system.yaml":
    ensure  => present,
    content => stdlib::to_yaml($_obmondo_system_facts),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    noop    => false,
  }

  #############
  # INCLUDES
  #############

  # NOTE: includes all these system profile, but some are set to enable
  # and some set to disable, depending on the requirement.
  lookup('common::system::classes').each | $subclass | {
    include $subclass
  }

  unless lookup('common::system::jumphost::configs', Hash, undef, {}).empty {
    include common::system::jumphost
  }
}
