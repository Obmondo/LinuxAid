# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'Rsyslog' do
  context 'with defaults' do
    before(:context) do
      cleanup_helper
    end

    it 'applies' do
      pp = <<-MANIFEST
      case $facts['os']['name'] {
        'Ubuntu': {
          $overrides = true
        }
        'RedHat', 'CentOS', 'Scientific', 'Fedora', 'OracleLinux': {
          $overrides = false
        }
      }
      class { 'rsyslog':
        override_default_config => $overrides,
        purge_config_files      => $overrides,
      }
      MANIFEST

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file('/etc/rsyslog.conf') do
      it { is_expected.to be_file }
      it { is_expected.to be_readable }
    end

    describe file('/etc/rsyslog.d') do
      it { is_expected.to be_directory }
      it { is_expected.to exist }
    end

    describe package('rsyslog') do
      it { is_expected.to be_installed }
    end

    describe service('rsyslog') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end
  end
end
