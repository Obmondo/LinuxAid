# frozen_string_literal: true

require 'voxpupuli/acceptance/spec_helper_acceptance'

configure_beaker do |host|
  host.install_package('software-properties-common') if fact_on(host, 'os.name') == 'Ubuntu'
end

def cleanup_helper
  pp = <<-CLEANUP_MANIFEST
    package { 'rsyslog-logrotate': ensure => absent }
    package { 'rsyslog': ensure => absent }
    file { '/etc/rsyslog.d': ensure => absent, purge => true, force => true }
    file { '/etc/rsyslog.conf': ensure => absent }
  CLEANUP_MANIFEST

  apply_manifest(pp, catch_failures: true)
end

def upstream_cleanup
  if fact('os.name') == 'Ubuntu' # rubocop:disable Style/GuardClause
    pp = <<-CLEANUP_MANIFEST
      include ::apt
      apt::ppa { 'ppa:adiscon/v8-stable': ensure => absent }
    CLEANUP_MANIFEST

    apply_manifest(pp, catch_failures: true)
  end
end
