# @summary Manage the install process for Windows OSes specifically.
# Private class called from puppet_agent class.
#
# @param install_options
#   An array of additional options to pass when installing puppet-agent. Each option in
#   the array can either be a string or a hash. Each option will automatically be quoted
#   when passed to the install command. With Windows packages, note that file paths in an
#   install option must use backslashes. (Since install options are passed directly to
#   the installation command, forward slashes won't be automatically converted like they
#   are in `file` resources.) Note also that backslashes in double-quoted strings _must_
#   be escaped and backslashes in single-quoted strings _can_ be escaped.
# @param install_dir
#   The directory the puppet agent should be installed to. This is only applicable for
#   windows operating systems.
class puppet_agent::install::windows (
  Optional $install_dir           = undef,
  Array[Variant[String, Hash]] $install_options = [],
) {
  assert_private()

  $service_names         = $puppet_agent::service_names

  $_msi_location = $puppet_agent::prepare::package::local_package_file_path

  $_install_options = $install_options ? {
    []      => windows_msi_installargs(['REINSTALLMODE="amus"']),
    default => windows_msi_installargs($install_options)
  }

  if (member($puppet_agent::service_names, 'puppet')) {
    $_agent_startup_mode = 'Automatic'
  } else {
    $_agent_startup_mode = undef
  }

  if $puppet_agent::msi_move_locked_files {
    if ($puppet_agent::_expected_package_version.match(/^5.5/) and versioncmp($puppet_agent::_expected_package_version, '5.5.17') < 0) or
    ($puppet_agent::_expected_package_version.match(/^6/) and versioncmp($puppet_agent::_expected_package_version, '6.8.0') < 0) {
      $_move_dll_workaround = '-UseLockedFilesWorkaround'
    } else {
      notify { 'Ignoring msi_move_locked_files setting as it is no longer needed with newer puppet-agent versions (puppet 5 >= 5.5.17 or puppet 6 >= 6.8.0)': }
      $_move_dll_workaround = undef
    }
  } else {
    $_move_dll_workaround = undef
  }

  if $puppet_agent::wait_for_pxp_agent_exit {
    $_pxp_agent_wait = "-WaitForPXPAgentExit ${puppet_agent::wait_for_pxp_agent_exit}"
  } else {
    $_pxp_agent_wait = undef
  }

  if $puppet_agent::wait_for_puppet_run {
    $_puppet_run_wait = "-WaitForPuppetRun ${puppet_agent::wait_for_puppet_run}"
  } else {
    $_puppet_run_wait = undef
  }

  $_timestamp = strftime('%Y_%m_%d-%H_%M')
  $_logfile = windows_native_path("${facts['env_temp_variable']}/puppet-${_timestamp}-installer.log")

  notice ("Puppet upgrade log file at ${_logfile}")
  debug ("Installing puppet from ${_msi_location}")

  $_helpers = windows_native_path("${facts['env_temp_variable']}/helpers.ps1")
  file { $_helpers:
    ensure  => file,
    content => file('puppet_agent/helpers.ps1'),
  }

  $_installps1 = windows_native_path("${facts['env_temp_variable']}/install_puppet.ps1")
  puppet_agent_upgrade_error { 'puppet_agent_upgrade_failure.log': }
  file { $_installps1:
    ensure  => file,
    content => file('puppet_agent/install_puppet.ps1'),
  }

  $_prerequisites_check = windows_native_path("${facts['env_temp_variable']}/prerequisites_check.ps1")
  file { $_prerequisites_check:
    ensure  => file,
    content => file('puppet_agent/prerequisites_check.ps1'),
  }

# lint:ignore:top_scope_facts
  exec { 'prerequisites_check.ps1':
    command => "${facts['os']['windows']['system32']}\\WindowsPowerShell\\v1.0\\powershell.exe \
                  -ExecutionPolicy Bypass \
                  -NoProfile \
                  -NoLogo \
                  -NonInteractive \
                  ${_prerequisites_check} ${::puppet_agent::_expected_package_version} ${_msi_location} ${_logfile}",
    require => File[$_prerequisites_check],
  }

  exec { 'install_puppet.ps1':
    # The powershell execution uses -Command and not -File because -File will interpolate the quotes
    # in a context like cmd.exe: https://docs.microsoft.com/en-us/powershell/scripting/components/console/powershell.exe-command-line-help?view=powershell-6#-file--
    # Because of this it's much cleaner to use -Command and use single quotes for each powershell param
    command => "${facts['os']['windows']['system32']}\\cmd.exe /S /c start /b ${facts['os']['windows']['system32']}\\WindowsPowerShell\\v1.0\\powershell.exe \
                  -ExecutionPolicy Bypass \
                  -NoProfile \
                  -NoLogo \
                  -NonInteractive \
                  -Command ${_installps1} \
                          -PuppetPID ${facts['puppet_agent_pid']} \
                          -Source '${_msi_location}' \
                          -Logfile '${_logfile}' \
                          -InstallDir '${install_dir}' \
                          -PuppetMaster '${facts['puppet_master_server']}' \
                          -PuppetStartType '${_agent_startup_mode}' \
                          -InstallArgs '${_install_options}' \
                          ${_move_dll_workaround} \
                          ${_pxp_agent_wait} \
                          ${_puppet_run_wait}",
    unless  => "${facts['os']['windows']['system32']}\\WindowsPowerShell\\v1.0\\powershell.exe \
                  -ExecutionPolicy Bypass \
                  -NoProfile \
                  -NoLogo \
                  -NonInteractive \
                  -Command {\$CurrentVersion = [string](facter.bat aio_agent_version); \
                            if (\$CurrentVersion -eq '${::puppet_agent::_expected_package_version}') { \
                              exit 0; \
                            } \
                            exit 1; }.Invoke()",
    path    => $facts['path'],
    require => [
      Puppet_agent_upgrade_error['puppet_agent_upgrade_failure.log'],
      File[$_installps1],
      Exec['prerequisites_check.ps1'],
    ],
  }
# lint:endignore

  # PUP-5480/PE-15037 Cache dir loses inheritable SYSTEM perms
  exec { 'fix inheritable SYSTEM perms':
    command => "${facts['os']['windows']['system32']}\\icacls.exe \"${facts['puppet_client_datadir']}\" /grant \"SYSTEM:(OI)(CI)(F)\"",
    unless  => "${facts['os']['windows']['system32']}\\cmd.exe /c ${facts['os']['windows']['system32']}\\icacls.exe \"${facts['puppet_client_datadir']}\" | findstr \"SYSTEM:(OI)(CI)(F)\"",
    require => Exec['install_puppet.ps1'],
  }
}
