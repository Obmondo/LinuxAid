# @summary A set of audit rules that are configured to satisfy DISA STIG compliance checks for EL7.
#
# The defaults for this profile generate a set of audit rules that conform to
# automated DISA STIG compliance checks for RHEL7. Satisfying the checks,
# instead of the intent of the security requirements, necessitates unoptimized
# rules. These unoptimized rules, in turn, negatively impact system performance.
#
# WARNING: **These rules may overload your system and/or log server!**
#
# When auditd performance is an issue, you may wish to
#
# * Disable capabilities that, despite being required by DISA STIG for RHEL7,
#   produce large amounts audit records of limited utility. `chmod` auditing
#   for all non-service users falls in this category.
#
# * Use the optimized 'auditd::config::audit_profiles::simp' profile, instead.
#   That profile is more comprehensive and performant.
#
#
# @param uid_min
#   The minimum UID for human users on the system. Any audit events generated
#   by users below this number will be ignored unless a corresponding rule
#   is inserted *before* the UID-limiting rule in the rules list.  When using
#   `auditd::rule`, you can create such a rule by setting the `absolute`
#   parameter to be 'first'.
#
# @param audit_unsuccessful_file_operations
#   Whether to audit unsuccessful file operations.  These are file operations
#   that fail with EACCES or EPERM error codes
#
# @param audit_unsuccessful_file_operations_tag
#   The tag to identify the unsuccessful file operations in an audit record
#
# @param audit_chown
#   Whether to audit `chown` operations for all non-service users.
#   These operations are provided by `chown`, `fchown`, `fchownat`,
#   and `lchown` system calls.
#
# @param audit_chown_tag
#   The tag to identify `chown` operations in an audit record
#
# @param audit_chmod
#   Whether to audit `chmod` operations for all non-service users.
#   These operations are provided by `chmod`, `fchmod`, and `fchmodat`
#   system calls.
#
# @param audit_chmod_tag
#   The tag to identify `chmod` operations in an audit record
#
# @param audit_attr
#   Whether to audit `xattr` operations for all non-service users.
#   These operations are provided by `setxattr`, `lsetxattr`, `fsetxattr`,
#   `removexattr`, `lremovexattr` and `fremovexattr` system calls.
#
# @param audit_attr_tag
#   The tag to identify `xattr` operations in an audit record
#
# @param audit_rename_remove
#   Whether to audit rename/remove operations for all non-service users.
#   These operations are provided by `rename`, `renameat`, `rmdir`,
#   `unlink`, and `unlinkat` system calls.
#
# @param audit_rename_remove_tag
#   The tag to identify rename/remove operations in an audit record
#
# @param audit_suid_sgid
#   Whether to audit `setuid`/`setgid` commands
#
# @param default_suid_sgid_cmds
#   The default list of `setuid`/`setgid` commands to be audited.
#   * Should not include commands audited by other rules.
#
# @param suid_sgid_cmds
#   Additional list of `setuid`/`setgid` commands to be audited.
#   You can use this to augment the `$default_suid_sgid_cmds`
#   per your site's needs.
#
# @param audit_suid_tag
#   The tag to identify `setuid` command execution in an audit record
#
# @param audit_sgid_tag
#   The tag to identify `setgid` command execution in an audit record
#
# @param audit_suid_sgid_tag
#   The tag to identify `setuid`/`setgid` command execution in an audit record
#
# @param audit_kernel_modules
#   Whether to audit kernel module operations
#
# @param audit_kernel_modules_tag
#   The tag to identify kernel module operations in an audit record
#
# @param audit_mount
#   Whether to audit mount operations
#
# @param audit_mount_tag
#   The tag to identify mount operations in an audit record
#
# @param audit_local_account
#   Whether to audit local account changes
#
# @param audit_local_account_tag
#   The tag to identify local account changes in an audit record
#
# @param audit_selinux_cmds
#   Whether to audit `chcon`, `semanage`, `setsebool`, and `setfiles` commands
#
# @param audit_selinux_cmds_tag
#   The tag to identify selinux command execution in an audit record
#
# @param audit_login_files
#   Whether to audit changes to login files
#
# @param audit_login_files_tag
#   The tag to identify login file changes in an audit record
#
# @param audit_cfg_sudoers
#   Whether to audit changes to sudoers configuration files
#
# @param audit_cfg_sudoers_tag
#   The tag to identify sudoers configuration file changes in an audit record
#
# @param audit_passwd_cmds
#   Whether to audit the execution of password commands, i.e., `passwd`,
#   `unix_chkpwd`, `gpasswd`, `chage`, `userhelper`
#
# @param audit_passwd_cmds_tag
#   The tag to identify password command execution in an audit record
#
# @param audit_priv_cmds
#   Whether to audit the execution of privilege-related commands, i.e.,
#   `su`, `sudo`, `newgrp`, `chsh`, and `sudoedit`
#
# @param audit_priv_cmds_tag
#   The tag to identify privilege-related command execution in an audit record
#
# @param audit_postfix_cmds
#   Whether to audit the execution of postfix-related commands, i.e.
#   `postdrop` and `postqueue`
#
# @param audit_postfix_cmds_tag
#   The tag to identify postfix-related command execution in an audit record
#
# @param audit_ssh_keysign_cmd
#   Whether to audit the execution of the `ssh-keysign` command
#
# @param audit_ssh_keysign_cmd_tag
#   The tag to identify `ssh-keysign` command execution in an audit record
#
# @param audit_crontab_cmd
#   Whether to audit the execution of the `crontab` command
#
# @param audit_crontab_cmd_tag
#   The tag to identify `crontab` command execution in an audit record
#
# @param audit_pam_timestamp_check_cmd
#   Whether to audit the execution of the `pam_timestamp_check` command
#
# @param audit_pam_timestamp_check_cmd_tag
#   The tag to identify `pam_timestamp_check` command execution in an audit
#   record
#
class auditd::config::audit_profiles::stig (
  Integer[0]       $uid_min                                = $::auditd::uid_min,
  Boolean          $audit_unsuccessful_file_operations     = true,
  String[1]        $audit_unsuccessful_file_operations_tag = 'access',
  Boolean          $audit_chown                            = true,
  String[1]        $audit_chown_tag                        = 'perm_mod',
  Boolean          $audit_chmod                            = true,
  String[1]        $audit_chmod_tag                        = 'perm_mod',
  Boolean          $audit_attr                             = true,
  String[1]        $audit_attr_tag                         = 'perm_mod',
  Boolean          $audit_rename_remove                    = true,
  String[1]        $audit_rename_remove_tag                = 'delete',
  Boolean          $audit_suid_sgid                        = true,
  Array[String[1]] $default_suid_sgid_cmds,                   #data in modules
  Array[String[1]] $suid_sgid_cmds                         = [],
  String[1]        $audit_suid_tag                         = 'setuid',
  String[1]        $audit_sgid_tag                         = 'setgid',
  String[1]        $audit_suid_sgid_tag                    = "${audit_suid_tag}/${audit_sgid_tag}",
  Boolean          $audit_kernel_modules                   = true,
  String[1]        $audit_kernel_modules_tag               = 'module-change',
  Boolean          $audit_mount                            = true,
  String[1]        $audit_mount_tag                        = 'privileged-mount',
  Boolean          $audit_local_account                    = true,
  String[1]        $audit_local_account_tag                = 'identity',
  Boolean          $audit_selinux_cmds                     = true,
  String[1]        $audit_selinux_cmds_tag                 = 'privileged-priv_change',
  Boolean          $audit_login_files                      = true,
  String[1]        $audit_login_files_tag                  = 'logins',
  Boolean          $audit_cfg_sudoers                      = true,
  String[1]        $audit_cfg_sudoers_tag                  = 'privileged-actions',
  Boolean          $audit_passwd_cmds                      = true,
  String[1]        $audit_passwd_cmds_tag                  = 'privileged-passwd',
  Boolean          $audit_priv_cmds                        = true,
  String[1]        $audit_priv_cmds_tag                    = 'privileged-priv_change',
  Boolean          $audit_postfix_cmds                     = true,
  String[1]        $audit_postfix_cmds_tag                 = 'privileged-postfix',
  Boolean          $audit_ssh_keysign_cmd                  = true,
  String[1]        $audit_ssh_keysign_cmd_tag              = 'privileged-ssh',
  Boolean          $audit_crontab_cmd                      = true,
  String[1]        $audit_crontab_cmd_tag                  = 'privileged-cron',
  Boolean          $audit_pam_timestamp_check_cmd          = true,
  String[1]        $audit_pam_timestamp_check_cmd_tag      = 'privileged-pam',
) {

  assert_private()
  $_suid_sgid_cmds = unique($default_suid_sgid_cmds + $suid_sgid_cmds)

  $_short_name = 'stig'
  $_idx = auditd::get_array_index($_short_name, $auditd::config::profiles)

  file { "/etc/audit/rules.d/50_${_idx}_${_short_name}_base.rules":
    mode    => $auditd::config::config_file_mode,
    content => epp("${module_name}/rule_profiles/stig/base.epp")
  }
}
