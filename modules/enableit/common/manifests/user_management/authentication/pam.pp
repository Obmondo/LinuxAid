# @summary Class for managing common::user_management::authentication::pam
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
# @param manage Boolean to manage PAM configuration. Defaults to $common::user_management::authentication::manage_pam.
#
# @param manage_pwquality Boolean to manage password quality. Defaults to false.
#
class common::user_management::authentication::pam (
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

  Boolean                             $manage                = $common::user_management::authentication::manage_pam,
  Boolean                             $manage_pwquality      = false,

) {
  if $manage {
    include profile::system::authentication::pam
  }
}
