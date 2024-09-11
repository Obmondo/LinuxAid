# == Class: gerrit::config
#
# This class does the basic configuration of Gerrit
#
# === Parameters
#
# This class accepts no parameters directly
#
# === Variables
#
# This class accepts no variables directly
#
# === Authors
#
# Andrew Grimberg <agrimberg@linuxfoundation.org>
#
# === Copyright
#
# Copyright 2014 Andrew Grimberg
#
class gerrit::config {
  $options = $gerrit::options
  $default_secure_options = $gerrit::params::default_secure_options
  $override_secure_options = $gerrit::override_secure_options

  $gerrit_home = $gerrit::gerrit_home
  $gerrit_user = $options['container']['user']
  validate_string($gerrit_user)

  # install gerrit site skin bits
  if ($gerrit::manage_site_skin) {
    # determine if any useful site options were passed
    $gerrit_site_options = $gerrit::gerrit_site_options

    ## GerritSite.css
    if has_key($gerrit_site_options, 'GerritSite.css') {
      validate_string($gerrit_site_options['GerritSite.css'])
      $gerrit_css = $gerrit_site_options['GerritSite.css']
    }
    else {
      $gerrit_css = 'puppet:///modules/gerrit/skin/GerritSite.css'
    }

    file { "${gerrit_home}/etc/GerritSite.css":
      owner  => $gerrit_user,
      group  => $gerrit_user,
      source => $gerrit_css,
    }

    ## GerritSiteHeader.html
    if has_key($gerrit_site_options, 'GerritSiteHeader.html') {
      validate_string($gerrit_site_options['GerritSiteHeader.html'])
      $gerrit_header = $gerrit_site_options['GerritSiteHeader.html']
    }
    else {
      $gerrit_header = 'puppet:///modules/gerrit/skin/GerritSiteHeader.html'
    }

    file { "${gerrit_home}/etc/GerritSiteHeader.html":
      owner  => $gerrit_user,
      group  => $gerrit_user,
      source => $gerrit_header,
    }

    ## GerritSiteFooter.html
    if has_key($gerrit_site_options, 'GerritSiteFooter.html') {
      validate_string($gerrit_site_options['GerritSiteFooter.html'])
      $gerrit_footer = $gerrit_site_options['GerritSiteFooter.html']
    }
    else {
      $gerrit_footer = 'puppet:///modules/gerrit/skin/GerritSiteFooter.html'
    }

    file { "${gerrit_home}/etc/GerritSiteFooter.html":
      owner  => $gerrit_user,
      group  => $gerrit_user,
      source => $gerrit_footer,
    }
  }

  # link up the service script
  file { 'gerrit_init_script':
    ensure => link,
    path   => '/etc/init.d/gerrit',
    target => "${gerrit_home}/bin/gerrit.sh",
  }

  # we need an /etc/default/gerritcodereview file to specify the
  # gerrit_home
  file { 'gerrit_defaults':
    ensure  => file,
    path    => '/etc/default/gerritcodereview',
    owner   => $gerrit_user,
    group   => $gerrit_user,
    mode    => '0644',
    content => template('gerrit/gerrit_defaults.erb'),
  }

  # gerrit configuration
  ::gerrit::config::git_config { 'gerrit.config':
    config_file => "${gerrit_home}/etc/gerrit.config",
    mode        => '0660',
    options     => $options,
  }

  # the secure options
  # auth.{registerEmailPrivateKey,restTokenPrivateKey} vars have the
  # option to be auto-generated using the create_token_string function.
  # If their values are set to GENERATE we need to do so
  #$generate_secure_options = {
  #  'auth'                      => {
  #    'registerEmailPrivateKey' => fqdn_token_string(34),
  #    'restTokenPrivateKey'     => fqdn_token_string(34,
  #      inline_template('<%= @fqdn.length %>')),
  #  },
  #}
  $generate_secure_options = {
    'auth'                      => {
      'registerEmailPrivateKey' => 'jhsdfkjertklhsdfjkhjhsdfjmhasdjhjd',
      'restTokenPrivateKey'     => 'wufqsxwregxyufqswxuwufqswzunfqwuwq',
    },
  }

  $generated_default_secure_options = merge($default_secure_options,
    $generate_secure_options)
  $real_secure_options = merge($generated_default_secure_options,
    $override_secure_options)

  ::gerrit::config::git_config { 'secure.config':
    config_file => "${gerrit_home}/etc/secure.config",
    mode        => '0600',
    options     => $real_secure_options,
  }

  include ::gerrit::config::db

  include ::gerrit::config::firewall
}
