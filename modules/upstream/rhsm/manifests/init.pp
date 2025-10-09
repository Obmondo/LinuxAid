# rhsm
#
# Subscribe the node to RHSM
#
# Copyright 2014 Ger Apeldoorn, unless otherwise noted.
#
# @summary Subscribe the node to RHSM
#
# @param rh_user User for the Customer Portal.
#   You need to specify either (rh_user and rh_password) or (org and activationkey)
# @param rh_password Password for the rh_user account
# @param org Organization to use
# @param activationkey Activationkey to use
# @param servername Servername, default provided
#   Used directly in rhsm.conf template
# @param serverprefix server.prefix to use
#   Used directly in rhsm.conf template
#   /rhsm for Satellite 6
#   /subscription for RHSM
# @param serverport server.port to use
#   Used directly in rhsm.conf template
# @param ca_cert_dir Server CA certificate location
# @param repo_ca_cert_filename File containting the CA cert to use when generating yum repo configs
#   katello-server-ca.pem for Satellite 6
#   redhat-uep.pem for RHSM
# @param repo_ca_cert_source URI, if set the content is used for CA file resource ${ca_cert_dir}/${repo_ca_cert_filename}
#   Possible values are puppet:, file: and http:
# @param manage_repos 1 if subscription manager should manage yum repos file or
#   0 if the subscription is only used for tracking purposes
# @param full_refresh_on_yum rhsm.full_refresh_on_yum
#   Used directly in rhsm.conf template
#   1 for Satellite 6
#   0 for RHSM
# @param proxy_hostname Proxy hostname
# @param proxy_scheme Proxy scheme
# @param proxy_port Proxy port
# @param proxy_user Proxy user
# @param proxy_password Proxy password
# @param no_proxy no_proxy definition
# @param baseurl Base URL for rhsm, default provided
# @param package_ensure Whether to install subscription-manager, directly passed to the `ensure` param of the package.
# @param enabled_subscription_ids A listing of subscription IDs to provide to the subscription-manager attach --pool command.
# @param enabled_repo_ids A listing of the Repo IDs to provide to the subscription-manager repo --enable command.
# @param server_timeout HTTP timeout in seconds
# @param inotify Inotify is used for monitoring changes in directories with certificates. When this directory is mounted using a network
#   file system without inotify notification support (e.g. NFS), then disabling inotify is strongly recommended.
# @param process_timeout
#   The time in seconds we will allow the rhsmd cron job to run before terminating the process.
# @param manage_repo_filename
#   Should puppet try to manage the repo file subscription-manager uses?
# @param repo_filename
#   The name of the repo file subscription-manager uses.
# @param plugin_settings
#   Hash of {section => {key => value } } for the yum/dnf plugin.
# @param package_profile_on_trans Run the package profile on each yum/dnf transaction 
#
# @example
#   include rhsm
#
# @example
#   # Hierafile:
#   ---
#   rhsm::rh_user: myuser
#   rhsm::rh_password: mypassword
#
# @author Ger Apeldoorn <info@gerapeldoorn.nl>
#
class rhsm (
  Optional[String[1]]    $rh_user                  = undef,
  Optional[String[1]]    $rh_password              = undef,
  Optional[String[1]]    $org                      = undef,
  Optional[String[1]]    $activationkey            = undef,
  Optional[Stdlib::Fqdn] $proxy_hostname           = undef,
  Enum['http', 'https']  $proxy_scheme             = 'http',
  Optional[Stdlib::Port] $proxy_port               = undef,
  Optional[String[1]]    $proxy_user               = undef,
  Optional[String[1]]    $proxy_password           = undef,
  Optional[String[1]]    $no_proxy                 = undef,
  Stdlib::Httpurl        $baseurl                  = 'https://cdn.redhat.com',
  Stdlib::Fqdn           $servername               = 'subscription.rhsm.redhat.com',
  Stdlib::Absolutepath   $serverprefix             = '/subscription',
  Stdlib::Port           $serverport               = 443,
  Stdlib::Absolutepath   $ca_cert_dir              = '/etc/rhsm/ca/',
  String[1]              $repo_ca_cert_filename    = 'redhat-uep.pem',
  Optional[String[1]]    $repo_ca_cert_source      = undef,
  Integer[0,1]           $manage_repos             = 1,
  Integer[0,1]           $full_refresh_on_yum      = 0,
  String[1]              $package_ensure           = 'installed',
  Array[String[1]]       $enabled_subscription_ids = [],
  Array[String[1]]       $enabled_repo_ids         = [],
  Integer[0,1]           $inotify                  = 1,
  Integer[0]             $server_timeout           = 180,
  Integer[0]             $process_timeout          = 300,
  Boolean                $manage_repo_filename     = true,
  Stdlib::Absolutepath   $repo_filename            = '/etc/yum.repos.d/redhat.repo',
  Hash                   $plugin_settings          = { 'main' => { 'enabled' => 1 } },
  Integer[0,1]           $package_profile_on_trans = 0,
) {
  if ($rh_user == undef and $rh_password == undef) and ($org == undef and $activationkey == undef) {
    fail("${module_name}: Must provide rh_user and rh_password or org and activationkey")
  }

  $_user = if $rh_user {
    if $rh_user.is_a(Deferred) {
      Deferred('inline_epp', [' --username="<%= $rh_user %>"', { 'rh_user' => $rh_user }])
    } else {
      " --username='${rh_user}'"
    }
  } else {
    ''
  }

  $_password = if $rh_password {
    if $rh_password.is_a(Deferred) {
      Deferred('inline_epp', [' --password="<%= $rh_password %>"', { 'rh_password' => $rh_password }])
    } else {
      " --password='${rh_password}'"
    }
  } else {
    ''
  }

  $_org = if $org {
    if $org.is_a(Deferred) {
      Deferred('inline_epp', [' --org="<%= $org %>"', { 'org' => $org }])
    } else {
      " --org='${org}'"
    }
  } else {
    ''
  }

  $_activationkey = if $activationkey {
    if $activationkey.is_a(Deferred) {
      Deferred('inline_epp', [' --activationkey="<%= $activationkey %>"', { 'activationkey' => $activationkey }])
    } else {
      " --activationkey='${activationkey}'"
    }
  } else {
    ''
  }

  $proxycli = if $proxy_hostname {
    if $proxy_user and $proxy_password {
      " --proxy=${proxy_scheme}://${proxy_hostname}:${proxy_port} --proxyuser=${proxy_user} --proxypass=${proxy_password}"
    } else {
      " --proxy=${proxy_scheme}://${proxy_hostname}:${proxy_port}"
    }
  } else {
    ''
  }

  package { 'subscription-manager':
    ensure => $package_ensure,
  }

  file { '/etc/rhsm/rhsm.conf':
    content => template("${module_name}/rhsm.conf.erb"),
    require => Package['subscription-manager'],
    notify  => Service['rhsmcertd'],
  }

  if $manage_repo_filename {
    if $package_ensure == 'absent' {
      file { $repo_filename:
        ensure => 'absent',
      }
    } else {
      file { $repo_filename:
        ensure => 'file',
      }
    }
  }

  unless empty($plugin_settings) {
    if $facts['os']['release']['major'] < '8' {
      $plugin_path = '/etc/yum/pluginconf.d/subscription-manager.conf'
    } else {
      $plugin_path = '/etc/dnf/plugins/subscription-manager.conf'
    }

    file { $plugin_path:
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp("${module_name}/ini.conf.epp", { 'stanzas' => $plugin_settings }),
      require => Package['subscription-manager'],
    }
  }

  if $repo_ca_cert_source {
    file { "${ca_cert_dir}/${repo_ca_cert_filename}":
      source  => $repo_ca_cert_source,
      mode    => '0644',
      require => Package['subscription-manager'],
      before  => File['/etc/rhsm/rhsm.conf'],
    }
  }

  rh_subscription { $enabled_subscription_ids:
    ensure => present,
  }

  rh_repo { $enabled_repo_ids:
    ensure => present,
  }

  if $_user.is_a(Deferred) or $_password.is_a(Deferred) or $_org.is_a(Deferred) or $_activationkey.is_a(Deferred) {
    $variables = {
      'name' => $facts['networking']['fqdn'],
      'user' => $_user,
      'password' => $_password,
      'org' => $_org,
      'activationkey' => $_activationkey,
      'proxycli' => $proxycli,
    }
    $_reg_command = Sensitive(Deferred('inline_epp', ['subscription-manager register --name="<%= $name %>"<%= $user %><%= $password %><%= $org %><%= $activationkey %><%= $proxycli %>', $variables]))
  } else {
    $_reg_command = Sensitive("subscription-manager register --name='${facts['networking']['fqdn']}'${_user}${_password}${_org}${_activationkey}${proxycli}")
  }
  exec { 'RHSM-register':
    command => $_reg_command,
    creates => '/etc/pki/consumer/cert.pem',
    path    => '/bin:/usr/bin:/usr/sbin',
    require => File['/etc/rhsm/rhsm.conf'],
  }
  -> Rh_subscription <||>
  -> Rh_repo <||>

  service { 'rhsmcertd':
    ensure => running,
    enable => true,
  }
}
