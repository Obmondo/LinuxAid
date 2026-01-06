# @summary Class for managing the sssd ldap auth check
#
# @param enable Boolean to enable or disable the auth check. Defaults to true.
#
# @param test_users Array of usernames to test. Defaults to an empty array.
#
# @param noop_value The noop value for the monitor. Defaults to $monitor::noop_value.
#
# @groups configuration enable, noop_value.
#
# @groups users test_users.
#
class monitor::system::service::sssd::auth (
  Boolean                $enable     = $monitor::system::service::sssd::enable,
  Array[Eit_types::User] $test_users = [],
  Eit_types::Noop_Value  $noop_value = $monitor::noop_value,
) inherits monitor::system::service::sssd {

  $_enable = $enable and $test_users.count > 0
  $_target_file = if $_enable {
    lookup('common::monitor::exporter::node::textfile_directory', Stdlib::AbsolutePath)
  }
  monitor::package('obmondo-sssd-user-check', $_enable)
  file { '/etc/default/obmondo-sssd-user-check':
    ensure  => ensure_present($_enable),
    content => "TARGET_FILE=${_target_file}
TEST_USERS=(${test_users.join(' ')})\n",
    noop    => $noop_value,
  }
  profile::cron::job { 'test sssd user lookup':
    enable     => $_enable,
    minute     => '*/10',
    user       => 'obmondo-admin',
    command    => '/opt/obmondo/bin/obmondo-sssd-user-check',
    require    => [
      File['/etc/default/obmondo-sssd-user-check'],
      Package['obmondo-sssd-user-check'],
    ],
    noop_value => $noop_value,
  }
}
