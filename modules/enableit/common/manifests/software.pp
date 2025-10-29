# @summary Class for managing common software installation and dependencies
#
class common::software {
  if lookup('common::software::dependencyagent::enable', Boolean, undef, false) {
    common::software::dependencyagent.include
  }

  if lookup('common::software::cloudamize::enable', Boolean, undef, false) {
    common::software::cloudamize.include
  }

  if lookup('common::software::microsoft_mde::enable', Boolean, undef, false) {
    common::software::microsoft_mde.include
  }

  if lookup('common::software::teleport::enable', Boolean, undef, false) {
    common::software::teleport.include
  }

  if lookup('common::software::rubrik::enable', Boolean, undef, false) {
    common::software::rubrik.include
  }

  if lookup('common::software::fwupd::enable', Boolean, undef, false) {
    common::software::fwupd.include
  }

  if lookup('common::software::vscode::enable', Boolean, undef, false) {
    common::software::vscode.include
  }

  if lookup('common::software::nvidia_driver::enable', Boolean, undef, false) {
    common::software::nvidia_driver.include
  }

  if lookup('common::software::insights::manage', Boolean, undef, false) {
    common::software::insights.include    # inclu

  }

  if lookup('common::software::vncserver::manage', Boolean, undef, false) {
    common::software::vncserver.include
  }

  if lookup('common::software::msftlinuxpatchautoassess::manage', Boolean, undef, false) {
    common::software::msftlinuxpatchautoassess.include
  }

  if lookup('common::software::walinuxagent::manage', Boolean, undef, false) {
    common::software::walinuxagent.include
  }

  if lookup('common::software::iptables_api::manage', Boolean, undef, false) {
    common::software::iptables_api.include
  }

  if lookup('common::software::ansoftrsmservice::manage', Boolean, undef, false) {
    common::software::ansoftrsmservice.include
  }

  if lookup('common::software::rustdesk::manage', Boolean, undef, false) {
    common::software::rustdesk.include
  }

  if lookup('common::software::pycharm::manage', Boolean, undef, false) {
    include common::software::pycharm
  }

  if lookup('common::software::miniforge::manage', Boolean, undef, false) {
    include common::software::miniforge
  }
}
