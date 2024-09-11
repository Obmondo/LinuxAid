# @summary Configure the audit daemon for use with a specified audit profile.
#
# Any variable that is not described here can be found in auditd.conf(5) and
# auditctl(8).
#
# @see auditd.conf(5)
# @see auditctl(8)
#
# @param enable
#   If true, enable auditing.
#
# @param default_audit_profile
#   Deprecated by `$default_audit_profiles`
#
# @param default_audit_profiles
#   The built-in audit profile(s) to use to provide global audit rule
#   configuration (error handling, buffer size, etc.) and a base set
#   of audit rules.
#   - When more than one profile is specified, the profile rules are
#     effectively concatenated in the order the profiles are listed.
#   - To add rules to the base set, use `auditd::rule`.
#   - To manage the audit rules, yourself, set this parameter to `[]`.
#   - @see `auditd::config::audit_profiles` for more details about this
#     configuration.
#
# @param audit_auditd_config
#   Set up an audit rule to audit the `auditd` configuration files.
#
# @param lname
#   An alias for the ``name`` variable in the configuration file. This is used
#   since ``$name`` is a reserved keyword in Puppet.
#
# @param ignore_anonymous
#   For built-in audit profiles, whether to drop anonymous and daemon
#   events, i.e., events for which ``auid`` is '-1' (aka '4294967295').
#   Audit records from these events are prolific but not useful.
#
# @param ignore_crond
#   For built-in audit profiles, whether to drop events related to cron
#   jobs. `cron` creates a lot of audit events that are not usually useful.
#
# @param ignore_time_daemons
#   Ignore time modifications by time daemons that are running on the system
#   since this is valid activity.
#
# @param ignore_crypto_key_user
#   Ignore CRYPTO_KEY_USER logs since these are generally noise.
#
# @param ignore_errors
#   Whether to set the `auditctl` '-i' option
#
# @param ignore_failures
#   Whether to set the `auditctl` '-c' option
#
# @param ignore_system_services
#   For built-in audit profiles, whether to ignore system service events,
#   i.e., events for which the ``auid`` is set but is less than the
#   minimum UID for human users on the system.  In most security guides,
#   this filter is attached to every system call rule.  So, by implementing
#   the filter in an upfront drop rule, this feature provides optimization
#   of that filtering.
#
# @param action_mail_acct
# @param admin_space_left
# @param admin_space_left_action
#
# @param at_boot
#   If true, modify the Grub settings to enable auditing at boot time.
#
# @param buffer_size
#   Value of the `auditctl` '-b' option
#
# @param backlog_wait_time
#
# @param disk_error_action
# @param disk_full_action
# @param disp_qos
#   `auditd` version 2 only
# @param dispatcher
#   `auditd` version 2 only
#
# @param failure_mode
#   Value of the `auditctl` '-f' option
#
# @param flush
# @param freq
#
# @param immutable
#   Whether or not to make the configuration immutable when using built-in
#   audit profiles.  Be aware that, should you choose to make the
#   configuration immutable, you will not be able to change your audit
#   rules without a reboot.
#
# @param log_file
#
# @param local_events
#   `auditd` version 3 only
#
# @param log_format
#   The output log format
#
#   * 'NOLOG' is deprecated as of auditd 2.5.2
#   * 'ENRICHED' is only available in auditd >= 2.6.0
#
# @param log_group
#
# @param loginuid_immutable
#   Sets the --loginuid-immutable option
#
#   * This has been noted to potentially cause issues with some types of
#     containers but a concrete explanation of what types has not yet been
#     found.
#
# @param max_log_file
# @param max_log_file_action
#
# @param max_restarts
#  sets the number of times a plugin will be restart.
#
# @param name_format
# @param num_logs
#
# @param  overflow_action
#  sets the overflow action.
#
# @param package_name
#   The name of the auditd package.
#
# @param package_ensure
#
# @param plugin_dir
#  sets the directory for the plugin configuration files.
#
# @param priority_boost
#
# @param q_depth
#  how big to make the internal queue of the audit event dispatcher
#
# @param rate
#   Value of the `auditctl` '-r' option
#
# @param root_audit_level
#   What level of auditing should be used for su-root activity in built-in
#   audit profiles that provide su-root rules. Be aware that setting this to
#   anything besides 'basic' may overwhelm your system and/or log server.
#   Options can be, 'basic', 'aggressive', 'insane'.  For the 'simp' audit
#   profile, these options are as follows:
#    - Basic: Safe syscall rules, should not follow program execution outside
#      of the base app
#    - Aggressive: Adds syscall rules for execve, rmdir and variants of rename
#      and unlink
#    - Insane: Adds syscall rules for write, creat and variants of chown,
#      fork, link and mkdir
#
# @param service_name
#   The name of the auditd service.
#
# @param space_left
# @param space_left_action
#
# @param syslog
#   If true, manage the settings for the syslog plugin
#   It was left defaulted to  simp_options::syslog value for backwards
#   compatability.
#   This does not  activate/deactivate the plugin.  That setting is
#   in the auditd::config::audisp::syslog::enable setting.  If syslog
#   is set to true, by default it will enable the syslog plugin in order
#   to be backwards compatable.  If you want to ensure the plugin is disabled,
#   set auditd::config::audisp::syslog::enable to false.
#   If this is set to false the plugin settings are not managed by puppet.
#
# @param target_selinux_types
#   A list of SELinux types to target, all others will be dropped
#
#   For systems that require all users and processes to be in a confined
#   namespace, you may find that only auditing unconfined types will be
#   sufficient since all other invalid system actions are already audited.
#
# @param uid_min
#   The minimum UID for human users on the system. For built-in audit profiles
#   when `$ignore_system_services` is true, any audit events generated
#   by users below this number will be ignored, unless a corresponding rule
#   is inserted *before* the UID-limiting rule in the rules list.  When using
#   `auditd::rule`, you can create such a rule by setting the `absolute`
#   parameter to be 'first'.
#
# @param verify_email auditd version 3 only
#
# @param write_logs
#   Whether or not to write logs to disk.
#
#   * The `NOLOG` option on `log_format` has been deprecated in newer versions
#     of `auditd` so this attempts to do "the right thing" when `log_format` is
#     set to `NOLOG` for legacy support.
#
# @author https://github.com/simp/pupmod-simp-auditd/graphs/contributors
#
class auditd (
  # Control Parameters
  Boolean                                 $enable                  = true,
  Optional[Variant[Enum['simp'],Boolean]] $default_audit_profile   = undef,
  Array[Auditd::AuditProfile]             $default_audit_profiles  = [ 'simp' ],
  Boolean                                 $audit_auditd_config     = true,
  String                                  $lname                   = $facts['fqdn'],

  # Rule Tweaks
  Boolean                                 $ignore_anonymous        = true,
  Boolean                                 $ignore_crond            = true,
  Boolean                                 $ignore_time_daemons     = true,
  Boolean                                 $ignore_crypto_key_user  = true,
  Boolean                                 $ignore_errors           = true,
  Boolean                                 $ignore_failures         = true,
  Boolean                                 $ignore_system_services  = true,

  # Configuration Parameters
  String[1]                               $action_mail_acct        = 'root', # CCE-27241-9
  Integer[0]                              $admin_space_left        = 50,
  Auditd::SpaceLeftAction                 $admin_space_left_action = 'SUSPEND', # CCE-27239-3 : No guarantee of e-mail server so sending to syslog.
  Boolean                                 $at_boot                 = true, # CCE-26785-6
  Integer[0]                              $buffer_size             = 16384,
  Integer[1,600000]                       $backlog_wait_time       = 60000,
  Auditd::DiskErrorAction                 $disk_error_action       = 'SUSPEND',
  Auditd::DiskFullAction                  $disk_full_action        = 'SUSPEND',
  Enum['lossy','lossless']                $disp_qos                = 'lossy',
  Stdlib::Absolutepath                    $dispatcher              = '/sbin/audispd',
  Integer[0]                              $failure_mode            = 1,
  Auditd::Flush                           $flush                   = 'INCREMENTAL',
  Integer[0]                              $freq                    = 20,
  Boolean                                 $immutable               = false,
  Optional[Boolean]                       $local_events            = undef,
  Stdlib::Absolutepath                    $log_file                = '/var/log/audit/audit.log',
  Enum['RAW','ENRICHED','NOLOG']          $log_format              = 'RAW',
  String                                  $log_group               = 'root',
  Boolean                                 $loginuid_immutable      = true,
  Integer[0]                              $max_log_file            = 24, # CCE-27550-3
  Auditd::MaxLogFileAction                $max_log_file_action     = 'ROTATE', # CCE-27237-7
  Optional[Integer[1]]                    $max_restarts            = undef,           #data            = 10, #auditd version 3.0 and later
  Auditd::NameFormat                      $name_format             = 'USER',
  Integer[0]                              $num_logs                = 5, # CCE-27522-2
  Optional[Auditd::Overflowaction]        $overflow_action          = undef,         # data in module
  String[1]                               $package_name            = 'audit',
  Simplib::PackageEnsure                  $package_ensure          = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' }),
  Stdlib::Absolutepath                    $plugin_dir,             # data in module
  Integer[0]                              $priority_boost          = 3,
  Integer[0]                              $q_depth                 = 400,
  Integer[0]                              $rate                    = 0,
  Auditd::RootAuditLevel                  $root_audit_level        = 'basic',
  String[1]                               $service_name            = 'auditd',
  Integer[0]                              $space_left              = $admin_space_left + 25, # needs to be larger than $admin_space_left or auditd will not start
  Auditd::SpaceLeftAction                 $space_left_action       = 'SYSLOG', # CCE-27238-5 : No guarantee of e-mail server so sending to syslog.
  Boolean                                 $syslog                  = simplib::lookup('simp_options::syslog', {'default_value' => false }),   # CCE-26933-2
  Optional[Array[Pattern['^.*_t$']]]      $target_selinux_types    = undef,
  Integer[0]                              $uid_min                 = Integer(pick(fact('uid_min'), 1000)),
  Optional[Boolean]                       $verify_email            = undef,
  Boolean                                 $write_logs              = $log_format ? { 'NOLOG' => false, default => true }
) {

  if $enable {
    unless $space_left > $admin_space_left {
      fail('Auditd requires $space_left to be greater than $admin_space_left, otherwise it will not start')
    }
    if $facts['auditd_version'] and ( versioncmp($facts['auditd_version'], '2.6.0') < 0 ) {
      if ( versioncmp($facts['auditd_version'], '2.5.2') < 0 ) {
        unless $write_logs {
          $_log_format = 'NOLOG'
        }
      }
      else {
        # Versions > 2.5.2 do not handle NOLOG
        if $log_format == 'NOLOG' {
          $_log_format = 'RAW'
        }

        $_write_logs = $write_logs
      }

      unless defined('$_log_format') {
        # ENRICHED was not added until 2.6.0
        if $log_format == 'ENRICHED' {
          $_log_format = 'RAW'
        }
        else {
          $_log_format = $log_format
        }
      }
    }
    else {
      # Versions >= 2.6.0 do not support NOLOG
      if $log_format == 'NOLOG' {
        $_log_format = 'RAW'
      }
      else {
        $_log_format = $log_format
      }

      $_write_logs = $write_logs
    }

    simplib::assert_metadata($module_name)

    # This is done here so that the kernel option can be properly removed if
    # auditing is to be disabled on the system.
    if $at_boot {
      $_grub_enable = true
    }
    else {
      $_grub_enable = false
    }

    include 'auditd::install'
    include 'auditd::config'
    include 'auditd::service'

    Class['auditd::install']
    -> Class['auditd::config']
    ~> Class['auditd::service']
    -> Class['auditd']

    Class['auditd::install'] -> Class['::auditd::config::grub']

  }
  else {
    $_grub_enable = false
  }

  # This is done deliberately so that you cannot conflict a direct call to
  # auditd::config::grub with an include somewhere else. auditd::config::grub
  # would normally be a private class but may be used independently if
  # necessary.
  class { 'auditd::config::grub': enable => $_grub_enable }
}
