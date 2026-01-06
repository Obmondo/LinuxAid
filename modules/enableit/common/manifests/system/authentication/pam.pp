# @summary Class for managing common::system::authentication::pam
#
# @param auth_lines Array of tuples containing integers (0-99) and strings representing authentication lines.
#
# @param account_lines Array of tuples containing integers (0-99) and strings representing account lines.
#
# @param password_lines Array of tuples containing integers (0-99) and strings representing password lines.
#
# @param session_lines Array of tuples containing integers (0-99) and strings representing session lines.
#
# @param password_auth_lines Array of tuples containing integers (0-99) and strings representing password authentication lines.
#
# @param password_account_lines Array of tuples containing integers (0-99) and strings representing password account lines.
#
# @param password_password_lines Array of tuples containing integers (0-99) and strings representing password password lines.
#
# @param password_session_lines Array of tuples containing integers (0-99) and strings representing password session lines.
#
# @param sshd_auth_lines Array of tuples containing integers (0-99) and strings representing SSHD authentication lines.
#
# @param sshd_account_lines Array of tuples containing integers (0-99) and strings representing SSHD account lines.
#
# @param sshd_password_lines Array of tuples containing integers (0-99) and strings representing SSHD password lines.
#
# @param sshd_session_lines Array of tuples containing integers (0-99) and strings representing SSHD session lines.
#
# @param manage Boolean to manage PAM configuration. Defaults to $common::system::authentication::manage_pam.
#
# @param allowed_users Allowed users list. Defaults to $common::system::authentication::allowed_users.
#
# @param allow_managed_users Boolean to allow managed users. Defaults to true.
#
# @param manage_pwquality Boolean to manage password quality. Defaults to false.
#
# @param nologin_allowed_group Array of Group, 0 or 1 elements, specifying allowed groups for nologin.
#
# @groups authentication auth_lines, password_auth_lines, sshd_auth_lines
#
# @groups account account_lines, password_account_lines, sshd_account_lines
#
# @groups password password_lines, password_password_lines, sshd_password_lines
#
# @groups session session_lines, password_session_lines, sshd_session_lines
#
# @groups management manage, manage_pwquality, allow_managed_users, nologin_allowed_group
#
# @groups users allowed_users
#
class common::system::authentication::pam (
  Array[Tuple[Integer[0,99], String]] $auth_lines,
  Array[Tuple[Integer[0,99], String]] $account_lines,
  Array[Tuple[Integer[0,99], String]] $password_lines,
  Array[Tuple[Integer[0,99], String]] $session_lines,
  Array[Tuple[Integer[0,99], String]] $password_auth_lines,
  Array[Tuple[Integer[0,99], String]] $password_account_lines,
  Array[Tuple[Integer[0,99], String]] $password_password_lines,
  Array[Tuple[Integer[0,99], String]] $password_session_lines,
  Array[Tuple[Integer[0,99], String]] $sshd_auth_lines,
  Array[Tuple[Integer[0,99], String]] $sshd_account_lines,
  Array[Tuple[Integer[0,99], String]] $sshd_password_lines,
  Array[Tuple[Integer[0,99], String]] $sshd_session_lines,

  Boolean                             $manage                = $common::system::authentication::manage_pam,
  Eit_types::Common::Allowed_users    $allowed_users         = $common::system::authentication::allowed_users,
  Boolean                             $allow_managed_users   = true,
  Boolean                             $manage_pwquality      = false,
  Array[Eit_types::Group, 0, 1]       $nologin_allowed_group = [],

) {
  if $manage {
    include profile::system::authentication::pam
  }
}
