# @summary
#   Profile for installing and configuring the Slurm Web components (slurm-slurmrestd, slurm-web-agent, slurm-web-gateway)
#   and managing their configuration files using typed structures.
#
# @description
#   This profile sets up the Slurm web interface components that provide a REST API and web UI for Slurm.
#   It installs the required packages (`slurm-slurmrestd`, `slurm-web-agent`, `slurm-web-gateway`), manages the systemd
#   service configuration for `slurmrestd`, and renders configuration files for each component
#   (`agent.ini`, `gateway.ini`, `policy.ini`) using custom EIT data types.
#
#   All configuration data is provided via typed parameters defined in the
#   `Eit_types::slurm` namespace, typically sourced from Hiera.
#
#   The following files are managed:
#     - `/etc/systemd/system/slurmrestd.service.d/slurm-web.conf`
#     - `/etc/slurm-web/agent.ini`
#     - `/etc/slurm-web/gateway.ini`
#     - `/etc/slurm-web/policy.ini`
#
#   The service `slurmrestd` is configured to run using JWT authentication, and the
#   gateway and agent services are configured with LDAP authentication and Slurm cluster details.
#
# @param enable
#   Whether to enable the `slurm_web` profile. When set to `false`, no changes are applied.
#   Typically controlled by a role-level variable: `$::role::computing::slurm::slurm_web`.
#
# @param noop_value
#   Enables Puppet noop mode for this profile. When `true`, Puppet will simulate changes without applying them.
#   Typically set from `$::role::computing::slurm::noop_value`.
#
# @param agent
#   Structured data for configuring the Slurm agent.
#   Uses the `Eit_types::slurm::agent` type, which defines:
#     * `service.cluster` — Cluster name to register with.
#     * `slurmrestd.jwt_mode` — JWT mode for authentication (`static` or `dynamic`).
#     * `slurmrestd.jwt_token` — JWT token string for REST API access.
#
# @param gateway
#   Structured data for configuring the Slurm gateway.
#   Uses the `Eit_types::slurm::gateway` type, which defines:
#     * `service.interface` — Hostname or interface where the gateway binds.
#     * `service.port` — Optional port number for the web UI.
#     * `ui.host` — Full URL for the UI (e.g., `http://hostname:5011`).
#     * `authentication.enabled` — Boolean to enable/disable authentication.
#     * `ldap` — LDAP connection details:
#         - `uri`, `user_base`, `group_base`
#         - `bind_dn`, `bind_password` (sensitive)
#         - Optional attributes such as `group_name_attribute`, `user_class`, etc.
#     * `agents.url` — URL for the agent API endpoint (e.g., `http://localhost:5012`).
#
# @param policy
#   Structured data for configuring Slurm web UI access policies.
#   Uses the `Eit_types::slurm::policy` type, which defines:
#     * `roles.user` — Comma-separated list of roles assigned to regular users.
#     * `roles.admin` — Comma-separated list of roles assigned to admins.
#     * `user.actions` — Actions permitted for users (e.g., `view-stats,view-jobs,view-nodes`).
#     * `admin.actions` — Actions permitted for admins (e.g., `view-partitions,view-qos,...`).
#
# @example Using the profile with data from Hiera
#   profile::computing::slurm::slurm_web:
#     enable: true
#     noop_value: false
#     agent:
#       service:
#         cluster: 'slurm-Cluster'
#       slurmrestd:
#         jwt_mode: 'static'
#         jwt_token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
#     gateway:
#       service:
#         interface: 'slurmserver01'
#         port: 5011
#       ui:
#         host: 'http://slurmserver01:5011'
#       authentication:
#         enabled: true
#       ldap:
#         uri: 'ldaps://AZWEUDCSGNH01.hearing.corp-ad.com:636'
#         user_base: 'OU=Others,OU=Administration Accounts,DC=xyz,DC=example,DC=com'
#         group_base: 'OU=Others,OU=Administration Accounts,DC=xyz,DC=example,DC=com'
#         bind_dn: 'admindroot'
#         bind_password: 'Sensitive[...]'
#       agents:
#         url: 'http://localhost:5012'
#     policy:
#       roles:
#         user: 'ALL'
#         admin: 'admindtiwari'
#       user:
#         actions: 'view-stats,view-jobs,view-nodes'
#       admin:
#         actions: 'view-partitions,view-qos,view-accounts,view-reservations'
#
class profile::computing::slurm::slurm_web (
  Boolean                   $enable     = $::role::computing::slurm::slurm_web,
  Boolean                   $noop_value = $::role::computing::slurm::noop_value,
  Eit_types::Slurm::Agent   $agent      = $::role::computing::slurm::slurm_agent,
  Eit_types::Slurm::Gateway $gateway    = $::role::computing::slurm::slurm_gateway,
  Eit_types::Slurm::Policy  $policy     = $::role::computing::slurm::slurm_policy,
) {

  # -------------------------------------------------------
  # Add RackDB repo
  # -------------------------------------------------------
  eit_repos::repo { 'rackslab_slurmweb':
    noop_value => $noop_value,
  }

  # -------------------------------------------------------
  # Install dependency packages
  # -------------------------------------------------------
  package { ['http-parser-devel', 'json-c-devel']:
    ensure => ensure_present($enable),
    noop   => $noop_value,
  }

  # -------------------------------------------------------
  # Install slurm-web packages
  # -------------------------------------------------------
  package { ['slurm-slurmrestd', 'slurm-web-agent', 'slurm-web-gateway']:
    ensure  => ensure_present($enable),
    require => Eit_repos::Repo['rackslab_slurmweb'],
    noop    => $noop_value,
  }

  # -------------------------------------------------------
  # Systemd override for slurmrestd
  # -------------------------------------------------------
  file { '/etc/systemd/system/slurmrestd.service.d':
    ensure  => ensure_dir($enable),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    noop    => $noop_value,
    require => Package['slurm-slurmrestd'],
  }

  file { '/etc/systemd/system/slurmrestd.service.d/slurm-web.conf':
    ensure  => ensure_file($enable),
    content => @(EOF/L),
      [Service]
      # Unset vendor unit ExecStart and Environment to avoid cumulative definition
      ExecStart=
      Environment=
      Environment="SLURM_JWT=daemon"
      ExecStart=/usr/sbin/slurmrestd $SLURMRESTD_OPTIONS -a rest_auth/jwt unix:/run/slurmrestd/slurmrestd.socket
      RuntimeDirectory=slurmrestd
      RuntimeDirectoryMode=0755
      User=slurmrestd
      Group=slurmrestd
      DynamicUser=yes
      | EOF
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Exec['systemd-daemon-reload'],
    noop    => $noop_value,
    require => Package['slurm-slurmrestd'],
  }

  exec { 'systemd-daemon-reload':
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
    noop        => $noop_value,
  }

  # -------------------------------------------------------
  # Configuration files
  # -------------------------------------------------------
  file { '/etc/slurm-web':
    ensure => ensure_dir($enable),
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    noop   => $noop_value,
  }

  file { '/etc/slurm-web/agent.ini':
    ensure  => ensure_file($enable),
    noop    => $noop_value,
    content => epp('profile/computing/slurm/slurmweb/agent.ini.epp', {
      agent_config => $agent,
    }),
    require => Package['slurm-web-agent'],
  }

  file { '/etc/slurm-web/gateway.ini':
    ensure  => ensure_file($enable),
    noop    => $noop_value,
    require => Package['slurm-web-gateway'],
    content => epp('profile/computing/slurm/slurmweb/gateway.ini.epp', {
      'gateway_config' => $gateway,
    }),
  }

  file { '/etc/slurm-web/policy.ini':
    ensure  => ensure_file($enable),
    noop    => $noop_value,
    require => Package['slurm-web-gateway'],
    content => epp('profile/computing/slurm/slurmweb/policy.ini.epp', {
      'policy' => $policy,
    }),
  }

  # since we are accessing the slurm-web with haproxy so masking the uwsgi service
  service { ['slurm-web-gateway-uwsgi.service', 'slurm-web-agent-uwsgi.service']:
    ensure => stopped,
    enable => mask,
  }
}
