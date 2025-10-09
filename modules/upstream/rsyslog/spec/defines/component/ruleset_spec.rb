# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

describe 'rsyslog::component::ruleset', include_rsyslog: true do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      let(:title) { 'myruleset' }

      context 'single call ruleset' do
        let(:params) do
          {
            priority: 65,
            target: '50_rsyslog.conf',
            confdir: '/etc/rsyslog.d',
            rules: [
              'call' => 'action.parse.rawmsg'
            ]
          }
        end

        it do
          is_expected.to contain_concat__fragment('rsyslog::component::ruleset::myruleset').with_content(
            %r{
              ruleset\s\(name="myruleset"
              \s+\)\s{
              \s+call\saction\.parse\.rawmsg
              \s+}$
            }x
          )
        end

        it { is_expected.to contain_class('rsyslog') }
        it { is_expected.to contain_concat('/etc/rsyslog.d/50_rsyslog.conf') }
        it { is_expected.to contain_rsyslog__generate_concat('rsyslog::concat::ruleset::myruleset') }
      end

      context 'ruleset with variables and call' do
        let(:params) do
          {
            priority: 65,
            target: '50_rsyslog.conf',
            confdir: '/etc/rsyslog.d',
            rules: [
              { 'set' => { '$.uuid' => '$uuid' } },
              { 'set' => { '$!rcv_time' => 'exec_template("s_rcv_time")' } },
              'call' => 'action.parse.r_msg'
            ]
          }
        end

        it do
          is_expected.to contain_concat__fragment('rsyslog::component::ruleset::myruleset').with_content(
            %r{(?x)\s*ruleset\s*\(name="myruleset"
            \s*\)\s*{
            \s*set\s*\$\.uuid\s*=\s*\$uuid;
            \s*set\s*\$!rcv_time\s*=\s*exec_template\("s_rcv_time"\);
            \s*call\s*action\.parse\.r_msg
            \s*}$}
          )
        end
      end

      context 'ruleset with parameters and a lookup' do
        let(:params) do
          {
            priority: 65,
            target: '50_rsyslog.conf',
            confdir: '/etc/rsyslog.d',
            parameters: {
              'parser' => 'pmrfc3164.hostname_with_slashes',
              'queue.size' => '10000'
            },
            rules: [
              { 'lookup' => { 'var' => 'srv', 'lookup_table' => 'srv-map', 'expr' => '$fromhost-ip' } }
            ]
          }
        end

        it do
          is_expected.to contain_concat__fragment('rsyslog::component::ruleset::myruleset').with_content(
            <<~EOS
              # myruleset ruleset
              ruleset (name="myruleset"
                parser="pmrfc3164.hostname_with_slashes"
                queue.size="10000"
              ) {

                set $.srv = lookup("srv-map", $fromhost-ip);
              }
            EOS
          )
        end
      end

      context 'ruleset with actions' do
        let(:params) do
          {
            priority: 65,
            target: '50_rsyslog.conf',
            confdir: '/etc/rsyslog.d',
            parameters: {
              'parser' => 'pmrfc3164.hostname_with_slashes',
              'queue.size' => '10000'
            },
            stop: true,
            rules: [
              {
                'action' => {
                  'name' => 'utf8-fix',
                  'type' => 'mmutf8fix',
                  'config' => {
                    'file' => '/var/log/fix'
                  }
                }
              },
              {
                'action' => {
                  'name' => 'myaction2',
                  'type' => 'omfile',
                  'config' => {
                    'dynaFile' => 'remoteSyslog',
                    'specifics' => '/var/log/test'
                  }
                }
              }
            ]
          }
        end

        it do
          is_expected.to contain_concat__fragment('rsyslog::component::ruleset::myruleset').with_content(
            <<~EOF
              # myruleset ruleset
              ruleset (name="myruleset"
                parser="pmrfc3164.hostname_with_slashes"
                queue.size="10000"
              ) {

                # utf8-fix
              action(type="mmutf8fix"
                  name="utf8-fix"
                  file="/var/log/fix"
                )


                # myaction2
              action(type="omfile"
                  name="myaction2"
                  dynaFile="remoteSyslog"
                  specifics="/var/log/test"
                )

                stop
              }
            EOF
          )
        end
      end

      context 'ruleset with expression-filter' do
        let(:facts) { { hostname: 'rsyslog_test' } }
        let(:params) do
          {
            priority: 65,
            target: '50_rsyslog.conf',
            confdir: '/etc/rsyslog.d',
            parameters: {
              'parser' => 'pmrfc3164.hostname_with_slashes',
              'queue.size' => '10000'
            },
            rules: [
              {
                'expression_filter' => {
                  'filter' => {
                    'if' => {
                      'expression' => '$hostname == "rsyslog_test"',
                      'tasks' => [
                        { 'call'        => 'action.ruleset.test' },
                        { 'stop'        => true }
                      ]
                    }
                  }
                }
              }
            ]
          }
        end

        it do
          is_expected.to contain_concat__fragment('rsyslog::component::ruleset::myruleset').with_content(
            <<~EOF
              # myruleset ruleset
              ruleset (name="myruleset"
                parser="pmrfc3164.hostname_with_slashes"
                queue.size="10000"
              ) {
              # Expression-based Filter
              if $hostname == "rsyslog_test" then {
                call action.ruleset.test
                stop
                }
              }
            EOF
          )
        end
      end

      context 'ruleset with property-filter' do
        let(:facts) { { hostname: 'rsyslog_test' } }
        let(:params) do
          {
            priority: 65,
            target: '50_rsyslog.conf',
            confdir: '/etc/rsyslog.d',
            parameters: {
              'parser' => 'pmrfc3164.hostname_with_slashes',
              'queue.size' => '10000'
            },
            rules: [
              {
                'property_filter' => {
                  'property' => 'msg',
                  'operator' => 'contains',
                  'value' => 'error',
                  'tasks' => [
                    { 'call'      => 'action.ruleset.test' },
                    { 'stop'      => true }
                  ]
                }
              }
            ]
          }
        end

        it do
          is_expected.to contain_concat__fragment('rsyslog::component::ruleset::myruleset').with_content(
            <<~EOF
              # myruleset ruleset
              ruleset (name="myruleset"
                parser="pmrfc3164.hostname_with_slashes"
                queue.size="10000"
              ) {
              # Property-based Filter
              :msg, contains, "error" {
                call action.ruleset.test
                stop
                }

              }
            EOF
          )
        end
      end

      context 'ruleset with execute program' do
        let(:params) do
          {
            priority: 65,
            target: '50_rsyslog.conf',
            confdir: '/etc/rsyslog.d',
            rules: [
              'exec' => '/bin/echo'
            ]
          }
        end

        it do
          is_expected.to contain_concat__fragment('rsyslog::component::ruleset::myruleset').with_content(
            %r{(?x)\s*ruleset\s*\(name="myruleset"
            \s*\)\s*{
            \s*\^/bin/echo
            \s*}$}
          )
        end
      end

      context 'error test' do
        let(:params) do
          {
            priority: 65,
            target: '50_rsyslog.conf',
            confdir: '/etc/rsyslog.d'
          }
        end

        it do
          is_expected.to compile.and_raise_error(%r{Ruleset MUST have at least one of: action, stop, set, call, or lookup})
        end
      end
    end
  end
end
