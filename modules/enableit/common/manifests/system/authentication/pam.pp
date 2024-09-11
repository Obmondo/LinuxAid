# PAM
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
