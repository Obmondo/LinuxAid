# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

describe 'Rsyslog::Component::Action', include_rsyslog: true do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      let(:title) { 'myaction' }

      context 'default action without facility' do
        let(:params) do
          {
            type: 'omelasticsearch',
            priority: 40,
            target: '50_rsyslog.conf',
            confdir: '/etc/rsyslog.d',
            config: {
              'queue.type' => 'linkedlist',
              'queue.spoolDirectory' => '/var/log/rsyslog/queue'
            }
          }
        end

        it do
          is_expected.to contain_concat__fragment('rsyslog::component::action::myaction').with_content(<<~CONTENT
            # myaction
            action(type="omelasticsearch"
                name="myaction"
                queue.type="linkedlist"
                queue.spoolDirectory="/var/log/rsyslog/queue"
              )
          CONTENT
                                                                                                      )
        end

        it { is_expected.to contain_concat('/etc/rsyslog.d/50_rsyslog.conf') }
        it { is_expected.to contain_rsyslog__generate_concat('rsyslog::concat::action::myaction') }
      end

      context 'facility with single line action' do
        let(:params) do
          {
            type: 'omfile',
            priority: 40,
            target: '50_rsyslog.conf',
            confdir: '/etc/rsyslog.d',
            facility: 'kern.*',
            config: {
              'dynaFile' => 'remoteKern'
            }
          }
        end

        it do
          is_expected.to contain_concat__fragment('rsyslog::component::action::myaction').with_content(%r{# myaction\n.*kern\.\*.*action\(type="omfile".*dynaFile="remoteKern".*\)})
        end
      end

      context 'facility with multiline action' do
        let(:params) do
          {
            type: 'omelasticsearch',
            priority: 40,
            target: '50_rsyslog.conf',
            confdir: '/etc/rsyslog.d',
            facility: '*.*',
            config: {
              'template' => 'plain-syslog',
              'searchIndex' => 'logstash-index',
              'queue.type' => 'linkedlist',
              'queue.spoolDirectory' => '/var/log/rsyslog/queue',
              'queue.filename' => 'dbq',
              'queue.maxdiskspace' => '100g',
              'queue.maxfilesize' => '100m',
              'queue.SaveOnShutdown' => 'on',
              'server' => 'logstash.domain.local',
              'action.resumeretrycount' => '-1',
              'bulkmode' => 'on',
              'dynSearchIndex' => 'on'
            }
          }
        end

        it do
          is_expected.to contain_concat__fragment('rsyslog::component::action::myaction').with_content(
            %r{# myaction\n.*\*\.\*.*action\(type="omelasticsearch".*\n.*template="plain-syslog".*\n.*searchIndex="logstash-index".*\n.*queue.type="linkedlist".*\n.*queue.spoolDirectory="/var/log/rsyslog/queue".*\n.*queue.filename="dbq".*\n.*queue.maxdiskspace="100g".*\n.*queue.maxfilesize="100m".*\n.*queue.SaveOnShutdown="on".*\n.*server="logstash.domain.local".*\n.*action.resumeretrycount="-1".*\n.*bulkmode="on".*\n.*dynSearchIndex="on".*\n.*\)}
          )
        end
      end
    end
  end
end
