# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog', include_rsyslog: true do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with defaults for all parameters' do
        it { is_expected.to contain_class('rsyslog') }
        it { is_expected.to contain_class('rsyslog::base') }
      end

      describe 'Rsyslog::Base' do
        context 'with defaults' do
          it { is_expected.to contain_package('rsyslog').with_ensure('installed') }
          it { is_expected.to contain_file('/etc/rsyslog.d').with_ensure('directory').that_requires('Package[rsyslog]') }
          it { is_expected.to contain_file('/etc/rsyslog.conf').with_ensure('file') }
          it { is_expected.to contain_service('rsyslog').with_ensure('running').with_enable(true) }
        end

        context 'with package not managed' do
          let(:params) { { 'manage_package' => false } }

          it { is_expected.not_to contain_package('rsyslog') }
        end

        context 'with feature packages' do
          let(:params) { { 'feature_packages' => %w[rsyslog-relp rsyslog-mmnormalize rsyslog-gnutls] } }

          it { is_expected.to contain_package('rsyslog-relp').with_ensure('installed') }
          it { is_expected.to contain_package('rsyslog-mmnormalize').with_ensure('installed') }
          it { is_expected.to contain_package('rsyslog-gnutls').with_ensure('installed') }
        end

        context "with upstream packages enabled on #{facts[:os]['name']}" do
          let(:params) { { 'use_upstream_repo' => true } }

          case facts[:os]['family']
          when 'Debian'
            it { is_expected.to contain_apt__ppa('ppa:adiscon/v8-stable') } if facts[:os]['name'] == 'Ubuntu'
          when 'RedHat'
            it { is_expected.to contain_yumrepo('upstream_rsyslog') } if facts[:os]['release']['major'].to_i < 9
          end
        end

        context 'with manage_confdir disabled' do
          let(:params) { { 'manage_confdir' => false } }

          it { is_expected.not_to contain_file('/etc/rsyslog.d') }
        end

        context 'with override_default_config disabled' do
          let(:params) { { 'override_default_config' => false } }

          it { is_expected.not_to contain_file('/etc/rsyslog.conf') }
        end

        context 'with manage_confdir and manage_service' do
          let(:params) do
            {
              'manage_service' => true,
              'manage_confdir' => true,
            }
          end

          it 'manages the rsyslog directory and restarts a service' do
            is_expected.to contain_file('/etc/rsyslog.d').
              with_ensure('directory').
              with_purge(true).
              that_notifies('Service[rsyslog]')
          end
        end

        context 'with service disabled' do
          let(:params) { { 'manage_service' => false } }

          it { is_expected.not_to contain_service('rsyslog') }
        end
      end
    end
  end
end
