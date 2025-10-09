# @summary A set of general purpose audit rules that should meet most security policy requirements
#
# The defaults for this profile generate a set of audit rules that are
# both usable on most systems and conformant with standard auditing
# requirements. A few key usage/implementation details about this profile
# should be noted:
#
#   * This profile uses optimized audit rules.  Specifically, it
#     * Combines system call rules as much as possible
#     * By default, uses initial drop rules for the `auid` filters that
#       would be otherwise applied to all system call rules
#     * By default, uses an initial drop rule for cron events that are
#       prolific, but whose audit records are of very limited utility
#   * Although all security requirements allow optimization of audit rules,
#     most of the automated security scanners do not yet understand audit
#     rule optimizations. So, use of this profile may require explanation
#     of these simple, yet effective, optimizations.
#   * You may overload your system and/or log server, if you enable the
#     highly-prolific, but limited-utility audit capabilities that have been
#     intentionally disabled, here, despite being required by specific
#     security standards.  'chmod' auditing for all non-service users
#     is an example of such a capability.
#   * In some cases, the more targeted set of rules for non-service users
#     that have su'd to root may provide a viable subset of required auditing.
#     This targeting filtering is enabled by `$audit_su_root_activity` and
#     customized by `$root_audit_level`, `$basic_root_audit_syscalls`,
#     `$aggressive_root_audit_syscalls, and `$insane_root_audit_syscalls`.
#
# @param root_audit_level
#   What level of auditing should be used for su-root activity. Be aware that
#   setting this to anything besides 'basic' may overwhelm your system and/or
#   log server.
#   Options can be, 'basic', 'aggressive', 'insane'
#    - Basic: Safe syscall rules, should not follow program execution outside
#      of the base app
#    - Aggressive: Adds syscall rules for execve, rmdir and variants of rename
#      and unlink
#    - Insane: Adds syscall rules for write, creat and variants of chown,
#      fork, link and mkdir
#
# @param audit_32bit_operations
#   In general, any 32bit system calls on a 64bit systems should be seen as
#   suspicious.
#
# @param audit_32bit_operations_tag
#   Tag to be added to entries triggered by `audit_32bit_operations`
#
# @param audit_auditd_cmds
#   Audit calls to the auditd management CLI commands
#
# @param audit_auditd_cmds_tag
#   Tag to be added to entries triggered by `audit_auditd_cmds`
#
# @param audit_auditd_cmds_list
#   Commands to be audited if enabled by `audit_auditd_cmds`
#
# @param basic_root_audit_syscalls
#   Basic syscalls to audit for su-root activity
#
# @param aggressive_root_audit_syscalls
#   Aggressive syscalls to audit for su-root activity
#
# @param insane_root_audit_syscalls
#   Insane syscalls to audit for su-root activity
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
#   The tag to identify `chown` operations in an audit record.
#   You should change this to 'perm_mod' to match automated DISA STIG
#   compliance checks for RHEL7.
#
# @param audit_chmod
#   Whether to audit `chmod` operations for all non-service users.
#   These operations are provided by `chmod`, `fchmod`, and `fchmodat`
#   system calls.
#
# @param audit_chmod_tag
#   The tag to identify `chmod` operations in an audit record.
#   You should change this to 'perm_mod' to match automated DISA STIG
#   compliance checks for RHEL7.
#
# @param audit_attr
#   Whether to audit `xattr` operations for all non-service users.
#   These operations are provided by `setxattr`, `lsetxattr`, `fsetxattr`,
#   `removexattr`, `lremovexattr` and `fremovexattr` system calls.
#
# @param audit_attr_tag
#   The tag to identify `xattr` operations in an audit record.
#   You should change this to 'perm_mod' to match automated DISA STIG
#   compliance checks for RHEL7.
#
# @param audit_rename_remove
#   Whether to audit rename/remove operations for all non-service users.
#   These operations are provided by `rename`, `renameat`, `rmdir`,
#   `unlink`, and `unlinkat` system calls.
#
# @param audit_rename_remove_tag
#   The tag to identify rename/remove operations in an audit record
#
# @param audit_su_root_activity
#   Whether to audit other useful actions someone does when su'ing to root.
#   The list of system calls audited is controlled by `$root_audit_level`.
#
# @param audit_su_root_activity_tag
#   The tag to identify `su` operations in an audit record
#
# @param audit_suid_sgid
#   Whether to audit `setuid`/`setgid` commands.
#   `setuid`/`setgid` command execution is audited by a single system call
#   rule.
#
# @param audit_suid_sgid_tag
#   The tag to identify `setuid`/`setgid` command execution in an audit
#   record. You should change this to 'setuid/setgid' to match automated
#   DISA STIG compliance checks for RHEL7.
#
# @param audit_kernel_modules
#   Whether to audit kernel module operations
#
# @param audit_kernel_modules_tag
#   The tag to identify kernel module operations in an audit record.
#   You should change this to 'module-change' to match automated DISA STIG
#   compliance checks for RHEL7.
#
# @param audit_time
#   Whether to audit operations that affect system time
#
# @param audit_time_tag
#   The tag to identify system time operations in an audit record
#
# @param audit_locale
#   Whether to audit operations that affect system locale
#
# @param audit_locale_tag
#   The tag to identify system locale operations in an audit record
#
# @param audit_network_ipv4_accept
#   Audit **incoming** IPv4 connections
#
# @param audit_network_ipv4_accept_tag
#   Tag to be added to entries triggered by `audit_network_ipv4_accept`
#
# @param audit_network_ipv6_accept
#   Audit **incoming** IPv6 connections
#
# @param audit_network_ipv6_accept_tag
#   Tag to be added to entries triggered by `audit_network_ipv6_accept`
#
# @param audit_network_ipv4_connect
#   Audit **outgoing** IPv4 connections
#
# @param audit_network_ipv4_connect_tag
#   Tag to be added to entries triggered by `audit_network_ipv4_connect`
#
# @param audit_network_ipv6_connect
#   Audit **outgoing** IPv6 connections
#
# @param audit_network_ipv6_connect_tag
#   Tag to be added to entries triggered by `audit_network_ipv6_connect`
#
# @param audit_mount
#   Whether to audit mount operations
#
# @param audit_mount_tag
#   The tag to identify mount operations in an audit record.
#   You should change this to 'privileged-mount' to match automated DISA STIG
#   compliance checks for RHEL7.
#
# @param audit_umask
#   Whether to audit umask changes
#
# @param audit_umask_tag
#   The tag to identify umask changes in an audit record
#
# @param audit_local_account
#   Whether to audit local account changes
#
# @param audit_local_account_tag
#   The tag to identify local account changes in an audit record.
#   You should change this to 'identity' to match the automated DISA STIG
#   compliance checks for RHEL7.
#
# @param audit_selinux_policy
#   Whether to audit selinux policy changes
#
# @param audit_selinux_policy_tag
#   The tag to identify selinux policy changes in an audit record
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
# @param audit_session_files
#   Whether to audit changes to session files
#
# @param audit_session_files_tag
#   The tag to identify session file changes in an audit record
#
# @param audit_sudoers
#   Deprecated by `$audit_cfg_sudoers`
#
# @param audit_sudoers_tag
#   Deprecated by `$audit_cfg_sudoers_tag`
#
# @param audit_cfg_sudoers
#   Whether to audit changes to sudoers configuration files
#
# @param audit_cfg_sudoers_tag
#   The tag to identify sudoers configuration file changes in an audit
#   record.  You should change this to 'privileged-actions' to match the
#   automated DISA STIG compliance checks for RHEL7.
#
# @param audit_grub
#   Deprecated by `$audit_cfg_grub`
#
# @param audit_grub_tag
#   Deprecated by `$audit_cfg_grub_tag`
#
# @param audit_cfg_grub
#   Whether to audit changes to grub configuration files
#
# @param audit_cfg_grub_tag
#   The tag to identify grub configuration file changes in an audit record
#
# @param audit_cfg_sys
#   Whether to audit changes to key system configuration files not
#   otherwise audited
#
# @param audit_cfg_sys_tag
#   The tag to identify changes to key system configuration files
#   not otherwise audited
#
# @param audit_cfg_cron
#   Whether to audit changes to cron configuration files
#
# @param audit_cfg_cron_tag
#   The tag to identify cron configuration file changes in an audit
#   record
#
# @param audit_cfg_shell
#   Whether to audit changes to global shell configuration files
#
# @param audit_cfg_shell_tag
#   The tag to identify global shell configuration file changes in an
#   audit record
#
# @param audit_cfg_pam
#   Whether to audit changes to PAM configuration files
#
# @param audit_cfg_pam_tag
#   The tag to identify PAM configuration file changes in an audit record
#
# @param audit_cfg_security
#   Whether to audit changes to `/etc/security`
#
# @param audit_cfg_security_tag
#   The tag to identify `/etc/security` file changes in an audit record
#
# @param audit_cfg_services
#   Whether to audit changes to `/etc/services`
#
# @param audit_cfg_services_tag
#   The tag to identify `/etc/services` file changes in an audit record
#
# @param audit_cfg_xinetd
#   Whether to audit changes to xinetd configuration files
#
# @param audit_cfg_xinetd_tag
#   The tag to identify xinetd configuration file changes in an audit record
#
# @param audit_yum
#   Deprecated by `$audit_cfg_yum`
#
# @param audit_yum_tag
#   Deprecated by `$audit_cfg_yum_tag`
#
# @param audit_cfg_yum
#   Whether to audit changes to yum configuration files
#
# @param audit_cfg_yum_tag
#   The tag to identify yum configuration file changes in an audit record
#
# @param audit_yum_cmd
#   Whether to audit `yum` command execution
#
# @param audit_yum_cmd_tag
#   The tag to identify `yum` command execution in an audit record
#
# @param audit_rpm_cmd
#   Whether to audit `rpm` command execution
#
# @param audit_rpm_cmd_tag
#   The tag to identify `rpm` command execution in an audit record
#
# @param audit_ptrace
#   Whether to audit `ptrace` system calls
#
# @param audit_ptrace_tag
#   The tag to identify `ptrace` system calls in an audit record
#
# @param audit_personality
#   Whether to audit `personality` system calls
#
# @param audit_personality_tag
#   The tag to identify `personality` system calls in an audit record
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
# @param audit_suspicious_apps
#   Audit various applications that generally represent suspicious host activity
#
# @param audit_suspicious_apps_tag
#   Tag to be added to entries triggered by `audit_suspicious_apps`
#
# @param audit_suspicious_apps_list
#   List of applications to be audited when `audit_suspicious_apps` is enabled
#
# @param audit_systemd
#   Audit systemd components
#
#   * Only takes effect on systems with systemd present
#
# @param audit_systemd_tag
#   Tag to be added to entries triggered by `audit_systemd`
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
class auditd::config::audit_profiles::simp (
  Auditd::RootAuditLevel      $root_audit_level                                         = $::auditd::root_audit_level,
  Boolean                     $audit_32bit_operations                                   = $facts['os']['hardware'] ? { 'x86_64' => true, default => false },
  String[1]                   $audit_32bit_operations_tag                               = '32bit-api',
  Boolean                     $audit_auditd_cmds                                        = true,
  String[1]                   $audit_auditd_cmds_tag                                    = 'access-audit-trail',
  Array[String[1]]            $audit_auditd_cmds_list,                                  # data in modules
  Boolean                     $audit_unsuccessful_file_operations                       = true,
  String[1]                   $audit_unsuccessful_file_operations_tag                   = 'access',
  Boolean                     $audit_chown                                              = true,
  String[1]                   $audit_chown_tag                                          = 'chown',
  Boolean                     $audit_chmod                                              = false,
  String[1]                   $audit_chmod_tag                                          = 'chmod',
  Boolean                     $audit_attr                                               = true,
  String[1]                   $audit_attr_tag                                           = 'attr',
  Boolean                     $audit_rename_remove                                      = false,
  String[1]                   $audit_rename_remove_tag                                  = 'delete',
  Boolean                     $audit_su_root_activity                                   = true,
  String[1]                   $audit_su_root_activity_tag                               = 'su-root-activity',
  Boolean                     $audit_suid_sgid                                          = true,
  String[1]                   $audit_suid_sgid_tag                                      = 'suid-exec',
  Boolean                     $audit_kernel_modules                                     = true,
  String[1]                   $audit_kernel_modules_tag                                 = 'modules',
  Boolean                     $audit_time                                               = true,
  String[1]                   $audit_time_tag                                           = 'audit_time_rules',
  Boolean                     $audit_locale                                             = true,
  String[1]                   $audit_locale_tag                                         = 'audit_network_modifications',
  Boolean                     $audit_network_ipv4_accept                                = true,
  String[1]                   $audit_network_ipv4_accept_tag                            = 'ipv4_in',
  Boolean                     $audit_network_ipv6_accept                                = true,
  String[1]                   $audit_network_ipv6_accept_tag                            = 'ipv6_in',
  Boolean                     $audit_network_ipv4_connect                               = false,
  String[1]                   $audit_network_ipv4_connect_tag                           = 'ipv4_in',
  Boolean                     $audit_network_ipv6_connect                               = false,
  String[1]                   $audit_network_ipv6_connect_tag                           = 'ipv6_in',
  Boolean                     $audit_mount                                              = true,
  String[1]                   $audit_mount_tag                                          = 'mount',
  Boolean                     $audit_umask                                              = false,
  String[1]                   $audit_umask_tag                                          = 'umask',
  Boolean                     $audit_local_account                                      = true,
  String[1]                   $audit_local_account_tag                                  = 'audit_account_changes',
  Boolean                     $audit_selinux_policy                                     = true,
  String[1]                   $audit_selinux_policy_tag                                 = 'MAC-policy',
  Boolean                     $audit_selinux_cmds                                       = false,
  String[1]                   $audit_selinux_cmds_tag                                   = 'privileged-priv_change',
  Boolean                     $audit_login_files                                        = true,
  String[1]                   $audit_login_files_tag                                    = 'logins',
  Boolean                     $audit_session_files                                      = true,
  String[1]                   $audit_session_files_tag                                  = 'session',
  Optional[Boolean]           $audit_sudoers                                            = undef,
  Optional[String[1]]         $audit_sudoers_tag                                        = undef,
  Boolean                     $audit_cfg_sudoers                                        = true,
  String[1]                   $audit_cfg_sudoers_tag                                    = 'CFG_sys',
  Optional[Boolean]           $audit_grub                                               = undef,
  Optional[String[1]]         $audit_grub_tag                                           = undef,
  Boolean                     $audit_cfg_grub                                           = true,
  String[1]                   $audit_cfg_grub_tag                                       = 'CFG_grub',
  Boolean                     $audit_cfg_sys                                            = true,
  String[1]                   $audit_cfg_sys_tag                                        = 'CFG_sys',
  Boolean                     $audit_cfg_cron                                           = true,
  String[1]                   $audit_cfg_cron_tag                                       = 'CFG_cron',
  Boolean                     $audit_cfg_shell                                          = true,
  String[1]                   $audit_cfg_shell_tag                                      = 'CFG_shell',
  Boolean                     $audit_cfg_pam                                            = true,
  String[1]                   $audit_cfg_pam_tag                                        = 'CFG_pam',
  Boolean                     $audit_cfg_security                                       = true,
  String[1]                   $audit_cfg_security_tag                                   = 'CFG_security',
  Boolean                     $audit_cfg_services                                       = true,
  String[1]                   $audit_cfg_services_tag                                   = 'CFG_services',
  Boolean                     $audit_cfg_xinetd                                         = true,
  String[1]                   $audit_cfg_xinetd_tag                                     = 'CFG_xinetd',
  Optional[Boolean]           $audit_yum                                                = undef,
  Optional[String[1]]         $audit_yum_tag                                            = undef,
  Boolean                     $audit_cfg_yum                                            = true,
  String[1]                   $audit_cfg_yum_tag                                        = 'yum-config',
  Boolean                     $audit_yum_cmd                                            = false,
  String[1]                   $audit_yum_cmd_tag                                        = 'package_changes',
  Boolean                     $audit_rpm_cmd                                            = false,
  String[1]                   $audit_rpm_cmd_tag                                        = 'package_changes',
  Boolean                     $audit_ptrace                                             = true,
  String[1]                   $audit_ptrace_tag                                         = 'paranoid',
  Boolean                     $audit_personality                                        = true,
  String[1]                   $audit_personality_tag                                    = 'paranoid',
  Boolean                     $audit_passwd_cmds                                        = true,
  String[1]                   $audit_passwd_cmds_tag                                    = 'privileged-passwd',
  Boolean                     $audit_priv_cmds                                          = true,
  String[1]                   $audit_priv_cmds_tag                                      = 'privileged-priv_change',
  Boolean                     $audit_postfix_cmds                                       = true,
  String[1]                   $audit_postfix_cmds_tag                                   = 'privileged-postfix',
  Boolean                     $audit_ssh_keysign_cmd                                    = true,
  String[1]                   $audit_ssh_keysign_cmd_tag                                = 'privileged-ssh',
  Boolean                     $audit_suspicious_apps                                    = true,
  String[1]                   $audit_suspicious_apps_tag                                = 'suspicious_apps',
  Array[Stdlib::Absolutepath] $audit_suspicious_apps_list,                              # data in modules
  Boolean                     $audit_systemd                                            = true,
  String[1]                   $audit_systemd_tag                                        = 'systemd',
  Boolean                     $audit_crontab_cmd                                        = true,
  String[1]                   $audit_crontab_cmd_tag                                    = 'privileged-cron',
  Boolean                     $audit_pam_timestamp_check_cmd                            = true,
  String[1]                   $audit_pam_timestamp_check_cmd_tag                        = 'privileged-pam',
  Array[String[1]]            $basic_root_audit_syscalls,                               # data in modules
  Array[String[1]]            $aggressive_root_audit_syscalls,                          # data in modules
  Array[String[1]]            $insane_root_audit_syscalls                               # data in modules
) {
  assert_private()

  if $audit_sudoers != undef {
    deprecation("${name}::audit_sudoers",
      "'${name}::audit_sudoers' is deprecated. Use '${name}::audit_cfg_sudoers' instead")
    $_audit_cfg_sudoers = $audit_sudoers
  } else {
    $_audit_cfg_sudoers = $audit_cfg_sudoers
  }

  if $audit_sudoers_tag != undef {
    deprecation("${name}::audit_sudoers_tag",
      "'${name}::audit_sudoers_tag' is deprecated. Use '${name}::audit_cfg_sudoers_tag' instead")
    $_audit_cfg_sudoers_tag = $audit_sudoers_tag
  } else {
    $_audit_cfg_sudoers_tag = $audit_cfg_sudoers_tag
  }

  if $audit_grub != undef {
    deprecation("${name}::audit_grub",
      "'${name}::audit_grub' is deprecated. Use '${name}::audit_cfg_grub' instead")
    $_audit_cfg_grub = $audit_grub
  } else {
    $_audit_cfg_grub = $audit_cfg_grub
  }

  if $audit_grub_tag != undef {
    deprecation("${name}::audit_grub_tag",
      "'${name}::audit_grub_tag' is deprecated. Use '${name}::audit_cfg_grub_tag' instead")
    $_audit_cfg_grub_tag = $audit_grub_tag
  } else {
    $_audit_cfg_grub_tag = $audit_cfg_grub_tag
  }

  if $audit_yum != undef {
    deprecation("${name}::audit_yum",
      "'${name}::audit_yum' is deprecated. Use '${name}::'audit_cfg_yum instead")
    $_audit_cfg_yum = $audit_yum
  } else {
    $_audit_cfg_yum = $audit_cfg_yum
  }

  if $audit_yum_tag != undef {
    deprecation("${name}::audit_yum_tag",
      "'${name}::audit_yum_tag' is deprecated. Use '${name}::'audit_cfg_yum_tag instead")
    $_audit_cfg_yum_tag = $audit_yum_tag
  } else {
    $_audit_cfg_yum_tag = $audit_cfg_yum_tag
  }

  $_short_name = 'simp'
  $_idx = auditd::get_array_index($_short_name, $auditd::config::profiles)

  file { "/etc/audit/rules.d/50_${_idx}_${_short_name}_base.rules":
    mode    => $auditd::config::config_file_mode,
    content => epp("${module_name}/rule_profiles/simp/base.epp")
  }
}
