# Common system
class common::system (
  Boolean                        $remove_fstrim_cron  = false,
  Boolean                        $purge_root_ssh_keys = true,
  Eit_types::Ssh_authorized_keys $ssh_authorized_keys = {},
  Eit_types::Users               $users               = {},
  Hash[String,Array[String]]     $user_groups         = {},
  Hash[String,Hash]              $groups              = {},
  Hash[String, Hash]             $services            = {},
  Hash[String,Hash]              $files               = {},
  Optional[Boolean]              $disable_ipv6        = undef,

  Hash[String, Array[Stdlib::IP::Address::V4]] $locations = {},
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

    $_options = if $v['options'] {
      $v['options'].map |$ok, $ov| {
        if empty($ov) {
          String($ok)
        } else {
          "${ok}=\"${ov}\""
        }
      }
    }

    ssh_authorized_key { $name:
      name    => pick($_ssh_key_match[3], $name),
      user    => $v['user'],
      type    => $_ssh_key_match[1],
      key     => $_ssh_key_match[2],
      noop    => $v['noop_value'],
      options => $_options,
      target  => "${home_dir_path}/.ssh/authorized_keys",
    }
  }

  ##############
  # SYSTEMD
  ##############

  if $facts['init_system'] == 'systemd' {
    include common::system::systemd
  }

  if $remove_fstrim_cron or $facts.dig('virtual') == 'lxc' {
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
    if $_source and $_source !~ Customers::Source {
      fail("Invalid file resource
           ${_element}")
    }

    customers::file { $key:
      * => $_file_parameters,
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
      if $ip_addr == $facts.dig('ipaddress') {
        $location
      } elsif stdlib::ip_in_range($facts.dig('ipaddress'), $ip_addr) {
        $location
      }
    }
  }.flatten.join('')

  $_puppet_dir = $facts['puppet_confdir'].dirname
  hocon_setting {
    default:
      ensure => present,
      path   => "${_puppet_dir}/facter/facts.d/obmondo_system.yaml",
      noop   => false,
      ;

    'facter location':
      setting => 'obmondo_system.location',
      value   => $_location,
      ;
  }

  #############
  # INCLUDES
  #############

  # NOTE: includes all these system profile, but some are set to enable
  # and some set to disable, depending on the requirement.
  include common::system::authentication
  include common::system::dns
  include common::system::kernel
  include common::system::grub
  include common::system::failover
  include common::system::hardware
  include common::system::limits
  include common::system::package_management
  include common::system::motd
  include common::system::nsswitch
  include common::system::sshd
  include common::system::time
  include common::system::cloud_init
  include common::system::selinux
  include common::system::updates
}
