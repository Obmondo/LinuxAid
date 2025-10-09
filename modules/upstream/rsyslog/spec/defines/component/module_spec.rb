# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

describe 'rsyslog::component::module', include_rsyslog: true do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      let(:title) { 'impstats' }

      context 'string action' do
        let(:params) do
          {
            type: 'external',
            priority: 20,
            target: '50_rsyslog.conf',
            confdir: '/etc/rsyslog.d',
            config: {
              'interval' => '60',
              'severity' => '7',
              'log.syslog' => 'off',
              'log.file' => '/var/log/rsyslog/logs/stats/stats.log',
              'Ruleset' => 'remote'
            }
          }
        end

        it do
          is_expected.to contain_concat__fragment('rsyslog::component::module::impstats').with_content(
            %r{
              module\(load="impstats"
              \s+interval="60"
              \s+severity="7"
              \s+log\.syslog="off"
              \s+log\.file="/var/log/rsyslog/logs/stats/stats.log"
              \s+Ruleset="remote"
              \s+\)
            }x
          )
        end

        it do
          is_expected.to contain_concat__fragment('rsyslog::component::module::impstats').with(
            'target' => '/etc/rsyslog.d/50_rsyslog.conf',
            'order' => 20
          )
        end

        it { is_expected.to contain_class('rsyslog') }
        it { is_expected.to contain_concat('/etc/rsyslog.d/50_rsyslog.conf') }
        it { is_expected.to contain_rsyslog__generate_concat('rsyslog::concat::module::impstats') }
      end
    end
  end
end
