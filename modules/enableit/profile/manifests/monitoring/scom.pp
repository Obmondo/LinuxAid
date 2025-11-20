# Microsoft SCOM
class profile::monitoring::scom (
  Optional[Array[Stdlib::Host]] $scom_masters       = $common::monitoring::scom::scom_masters,
  Boolean                       $install_sudo_rules = $common::monitoring::scom::install_sudo_rules,
  Eit_types::User               $scom_user          = $common::monitoring::scom::scom_user,
  Eit_types::Noop_Value         $noop_value         = $common::monitoring::scom::noop_value,
) inherits ::profile {

  if !$scom_masters.empty {
    firewall { '100 allow microsoft scom agent':
      proto  => 'tcp',
      dport  => 1270,
      jump   => 'accept',
      source => $scom_masters,
      noop   => $noop_value,
    }
  }

  if $install_sudo_rules {
    # Copied from
    # https://gitlab.enableit.dk/snippets/597
    profile::system::sudoers::conf {
      "${scom_user} scom agent notty":
        content    => 'Defaults:svclinuxmon !requiretty',
        noop_value => $noop_value,
      ;

      # Certificate signing
      "${scom_user} scom agent certificate siging":
        content    => "${scom_user} ALL=(root) NOPASSWD: /bin/sh -c cp /tmp/scx-svclinuxmon/scx.pem /etc/opt/microsoft/scx/ssl/scx.pem; rm -rf /tmp/scx-svclinuxmon; /opt/microsoft/scx/bin/tools/scxadmin -restart", # lint:ignore:140chars
        noop_value => $noop_value,
      ;

      # cat certificate
      "${scom_user} scom agent cat certificate":
        content    => "${scom_user} ALL=(root) NOPASSWD: /bin/sh -c cat /etc/opt/microsoft/scx/ssl/scx.pem",
        noop_value => $noop_value,
      ;

      # Copy config
      "${scom_user} scom agent copy config":
        content    => "${scom_user} ALL=(root) NOPASSWD: /bin/sh -c if test -f /opt/microsoft/omsagent/bin/service_control; then cp /tmp/scx-svclinuxmon/omsadmin.conf /etc/opt/microsoft/omsagent/scom/conf/omsadmin.conf; /opt/microsoft/omsagent/bin/service_control restart scom; fi", # lint:ignore:140chars
        noop_value => $noop_value,
      ;

      # Get OSversion
      "${scom_user} scom agent get osversion":
        content    => sprintf('%s ALL=(root) NOPASSWD: /bin/sh -c sh /tmp/scx-svclinuxmon/GetOSVersion.sh; EC=$?; rm -rf /tmp/scx-svclinuxmon; exit $EC', $scom_user), # lint:ignore:140chars
        noop_value => $noop_value,
      ;

      # Install
      "${scom_user} scom agent install agent":
        content    => sprintf('%s ALL=(root) NOPASSWD: /bin/sh -c sh /tmp/scx-svclinuxmon/scx-1.[5-9].[0-9]-[0-9][0-9][0-9].universal[[\:alpha\:]].[[\:digit\:]].x[6-8][4-6].sh --install --enable-opsmgr; EC=$?; cd /tmp; rm -rf /tmp/scx-svclinuxmon; exit $EC', $scom_user), # lint:ignore:140chars
        noop_value => $noop_value,
      ;

      # Upgrade
      "${scom_user} scom agent upgrade agent":
        content    => sprintf('%s ALL=(root) NOPASSWD: /bin/sh -c sh /tmp/scx-svclinuxmon/scx-1.[5-9].[0-9]-[0-9][0-9][0-9].universal[[\:alpha\:]].[[\:digit\:]].x[6-8][4-6].sh --upgrade --enable-opsmgr; EC=$?; cd /tmp; rm -rf /tmp/scx-svclinuxmon; exit $EC', $scom_user), # lint:ignore:140chars
        noop_value => $noop_value,
      ;

      # Uninstall
      "${scom_user} scom agent uninstall agent":
        content    => sprintf('%s ALL=(root) NOPASSWD: /bin/sh -c if test -f /opt/microsoft/omsagent/bin/omsadmin.sh; then if test "$(/opt/microsoft/omsagent/bin/omsadmin.sh -l | grep scom | wc -l)" \= "1" && test "$(/opt/microsoft/omsagent/bin/omsadmin.sh -l | wc -l)" \= "1" || test "$(/opt/microsoft/omsagent/bin/omsadmin.sh -l)" \= "No Workspace"; then /opt/microsoft/omsagent/bin/uninstall; else /opt/microsoft/omsagent/bin/omsadmin.sh -x scom; fi; else /opt/microsoft/scx/bin/uninstall; fi', $scom_user), # lint:ignore:140chars
        noop_value => $noop_value,
      ;

      # Log file monitoring
      "${scom_user} scom agent log monitoring":
        content    => "${scom_user} ALL=(root) NOPASSWD: /opt/microsoft/scx/bin/scxlogfilereader -p",
        noop_value => $noop_value,
      ;

      # Monitoring examples
      "${scom_user} scom agent test echo":
        content    => "${scom_user} ALL=(root) NOPASSWD: /bin/sh -c echo error",
        noop_value => $noop_value,
      ;
    }
  }
}
