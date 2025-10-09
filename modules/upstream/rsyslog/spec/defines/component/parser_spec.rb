# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

describe 'rsyslog::component::parser', include_rsyslog: true do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      let(:title) { 'pmrfc3164.hostname_with_slashes' }

      context 'pmrfc3164 parser' do
        let(:params) do
          {
            type: 'pmrfc3164',
            priority: 45,
            target: '50_rsyslog.conf',
            confdir: '/etc/rsyslog.d',
            config: {
              'permit.slashesinhostname' => 'on'
            }
          }
        end

        it do
          is_expected.to contain_concat__fragment('rsyslog::component::parser::pmrfc3164.hostname_with_slashes').with_content(
            %r{
              pmrfc3164.hostname_with_slashes
              \s+parser\(name="pmrfc3164.hostname_with_slashes"
              \s+type="pmrfc3164"
              \s+permit.slashesinhostname="on"
              \s+\)
            }x
          )
        end

        it { is_expected.to contain_class('rsyslog') }
        it { is_expected.to contain_concat('/etc/rsyslog.d/50_rsyslog.conf') }
        it { is_expected.to contain_rsyslog__generate_concat('rsyslog::concat::parser::pmrfc3164.hostname_with_slashes') }
      end
    end
  end
end
