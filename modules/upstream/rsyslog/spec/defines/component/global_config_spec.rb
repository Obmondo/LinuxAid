# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

describe 'rsyslog::component::global_config', include_rsyslog: true do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      let(:title) { 'configoption' }

      context 'when configuring a legacy type value' do
        let(:params) do
          {
            type: 'legacy',
            value: 'on',
            priority: 40,
            target: '50_rsyslog.conf',
            confdir: '/etc/rsyslog.d'
          }
        end

        it do
          is_expected.to contain_concat__fragment('rsyslog::component::global_config::configoption').with_content(
            %r{\$configoption\son\n}
          )
        end

        it { is_expected.to contain_class('rsyslog') }
        it { is_expected.to contain_concat('/etc/rsyslog.d/50_rsyslog.conf') }
        it { is_expected.to contain_rsyslog__generate_concat('rsyslog::concat::global_config::configoption') }
      end
    end
  end
end
