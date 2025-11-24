# PAM
class profile::system::authentication::pam (
  Boolean                              $manage                  = $common::system::authentication::pam::manage,
  Eit_types::Common::Allowed_users     $allowed_users           = $common::system::authentication::pam::allowed_users,
  Boolean                              $allow_managed_users     = $common::system::authentication::pam::allow_managed_users,
  Boolean                              $manage_pwquality        = $common::system::authentication::pam::manage_pwquality,
  Array[Eit_types::Group, 0, 1]        $nologin_allowed_group   = $common::system::authentication::pam::nologin_allowed_group,
  Array[Tuple[Integer[0,99], String]]  $auth_lines              = $common::system::authentication::pam::auth_lines,
  Array[Tuple[Integer[0,99], String]]  $account_lines           = $common::system::authentication::pam::account_lines,
  Array[Tuple[Integer[0,99], String]]  $password_lines          = $common::system::authentication::pam::password_lines,
  Array[Tuple[Integer[0,99], String]]  $session_lines           = $common::system::authentication::pam::session_lines,
  Array[Tuple[Integer[0,99], String]]  $password_auth_lines     = $common::system::authentication::pam::password_auth_lines,
  Array[Tuple[Integer[0,99], String]]  $password_account_lines  = $common::system::authentication::pam::password_account_lines,
  Array[Tuple[Integer[0,99], String]]  $password_password_lines = $common::system::authentication::pam::password_password_lines,
  Array[Tuple[Integer[0,99], String]]  $password_session_lines  = $common::system::authentication::pam::password_session_lines,
  Array[Tuple[Integer[0,99], String]]  $sshd_auth_lines         = $common::system::authentication::pam::sshd_auth_lines,
  Array[Tuple[Integer[0,99], String]]  $sshd_account_lines      = $common::system::authentication::pam::sshd_account_lines,
  Array[Tuple[Integer[0,99], String]]  $sshd_password_lines     = $common::system::authentication::pam::sshd_password_lines,
  Array[Tuple[Integer[0,99], String]]  $sshd_session_lines      = $common::system::authentication::pam::sshd_session_lines,
) {

  $system_user = lookup('common::system::users', { default_value => {} })

  # Users that we manage that do not have ensure=>absent
  $_managed_users = if $allow_managed_users {
    $system_user.filter |$_userid, $_user_config| {
      # remove system accounts; the should not be able to log in
      $_user_config.dig('system') != true
    }.filter |$_x| {
      # remove users that have `ensure => absent`
      $_x[1].dig('ensure') != 'absent'
    }
  } else {
    []
  }

  $_enable_quotas = lookup('common::storage::quota::enable', Boolean, undef, false) and lookup('common::storage::quota::quotas', Hash, undef, {}).size > 0 # lint:ignore:140chars

  $_password_session_lines_default = [
    if $_enable_quotas {
      [
        45,
        'required pam_exec.so debug /opt/obmondo/sbin/obmondo_set_quota',
      ]
    }
  ].delete_undef_values

  $_sshd_account_line =
    if ! empty($nologin_allowed_group) {
      $sshd_account_lines + [[20, "required      [default=ignore success=ok] pam_succeed_if.so quiet user ingroup ${nologin_allowed_group[0]}"]] # lint:ignore:140chars
    }
    else {
      $sshd_account_lines
    }

  class { 'pam':
    allowed_users               => $allowed_users.functions::knockout + $_managed_users,
    manage_nsswitch             => false,
    manage_pwquality            => !$manage_pwquality,
    pam_d_sshd_template         => 'pam/sshd.custom.erb',
    pam_auth_lines              => functions::generate_pam_lines($auth_lines, 'auth'),
    pam_account_lines           => functions::generate_pam_lines($account_lines, 'account'),
    pam_password_lines          => functions::generate_pam_lines($password_lines, 'password'),
    pam_session_lines           => functions::generate_pam_lines($session_lines, 'session'),
    pam_password_auth_lines     => functions::generate_pam_lines($password_auth_lines, 'auth'),
    pam_password_account_lines  => functions::generate_pam_lines($password_account_lines, 'account'),
    pam_password_password_lines => functions::generate_pam_lines($password_password_lines, 'password'),
    pam_password_session_lines  => functions::generate_pam_lines(
      $password_session_lines + $_password_session_lines_default, 'session'),
    pam_sshd_auth_lines         => functions::generate_pam_lines($sshd_auth_lines, 'auth'),
    pam_sshd_account_lines      => functions::generate_pam_lines($_sshd_account_line, 'account'),
    pam_sshd_password_lines     => functions::generate_pam_lines($sshd_password_lines, 'password'),
    pam_sshd_session_lines      => functions::generate_pam_lines($sshd_session_lines, 'session'),
  }

  if $manage_pwquality {
    class { 'pam::pwquality':
      difok     => 4,
      minlen    => 10,
      dcredit   => -1,
      ucredit   => -1,
      lcredit   => -1,
      ocredit   => -1,
      maxrepeat => 3,
    }
  }
}
