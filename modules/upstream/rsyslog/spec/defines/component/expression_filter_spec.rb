# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

describe 'rsyslog::component::expression_filter', include_rsyslog: true do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      let(:title) { 'myexpressionfilter' }

      context 'initial test' do
        let(:params) do
          {
            priority: 55,
            target: '50_rsyslog.conf',
            confdir: '/etc/rsyslog.d',
            conditionals: {
              if: {
                expression: 'msg == "test"',
                tasks: [
                  { action: {
                    name: 'myaction',
                    type: 'omfile',
                    config: {
                      dynaFile: 'remoteSyslog'
                    }
                  } }
                ]
              },
              else: {
                tasks: [
                  { action: {
                    name: 'myaction2',
                    type: 'omfwd',
                    config: {
                      KeepAlive: 'on'
                    }
                  } }
                ]
              }
            }
          }
        end

        it do
          is_expected.to contain_concat__fragment('rsyslog::component::expression_filter::myexpressionfilter').with_content(
            <<~CONTENT
              # myexpressionfilter
              if msg == "test" then {
                # myaction
              action(type="omfile"
                  name="myaction"
                  dynaFile="remoteSyslog"
                )

              }
              else {
                # myaction2
              action(type="omfwd"
                  name="myaction2"
                  KeepAlive="on"
                )

              }
            CONTENT
          )
        end

        it { is_expected.to contain_class('rsyslog') }
        it { is_expected.to contain_concat('/etc/rsyslog.d/50_rsyslog.conf') }
        it { is_expected.to contain_rsyslog__generate_concat('rsyslog::concat::expression_filter::myexpressionfilter') }
      end
    end
  end
end
