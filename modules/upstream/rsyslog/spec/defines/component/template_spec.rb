# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

describe 'rsyslog::component::template', include_rsyslog: true do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      let(:title) { 'mytpl' }

      context 'string template' do
        let(:params) do
          {
            type: 'string',
            priority: 30,
            target: '50_rsyslog.conf',
            confdir: '/etc/rsyslog.d',
            string: '/var/log/rsyslog/logs/%fromhost-ip%/%fromhost-ip%.log'
          }
        end

        it do
          is_expected.to contain_concat__fragment('rsyslog::component::template::mytpl').with_content(
            %r{
              template\s\(name="mytpl"\stype="string"
              \s+string="/var/log/rsyslog/logs/%fromhost-ip%/%fromhost-ip%.log"\s\)
            }x
          )
        end

        it { is_expected.to contain_class('rsyslog') }
        it { is_expected.to contain_concat('/etc/rsyslog.d/50_rsyslog.conf') }
        it { is_expected.to contain_rsyslog__generate_concat('rsyslog::concat::template::mytpl') }
      end

      context 'plugin template' do
        let(:params) do
          {
            type: 'plugin',
            priority: 30,
            target: '50_rsyslog.conf',
            confdir: '/etc/rsyslog.d',
            plugin: 'mystringgen'
          }
        end

        it do
          is_expected.to contain_concat__fragment('rsyslog::component::template::mytpl').with_content(
            %r{
              template\s\(name="mytpl"\stype="plugin"
              \s+plugin="mystringgen"\s\)
            }x
          )
        end
      end

      context 'subtree template' do
        let(:params) do
          {
            type: 'subtree',
            priority: 30,
            target: '50_rsyslog.conf',
            confdir: '/etc/rsyslog.d',
            subtree: '$!usr!tpl2'
          }
        end

        it do
          is_expected.to contain_concat__fragment('rsyslog::component::template::mytpl').with_content(
            %r{
              template\s\(name="mytpl"\stype="subtree"
              \s+subtree="\$!usr!tpl2"\s\)
            }x
          )
        end
      end

      context 'template with options' do
        let(:params) do
          {
            type: 'string',
            priority: 30,
            target: '50_rsyslog.conf',
            confdir: '/etc/rsyslog.d',
            string: '/var/log/rsyslog/logs/%fromhost-ip%/%fromhost-ip%.log',
            options: { 'sql' => 'on' }
          }
        end

        it do
          is_expected.to contain_concat__fragment('rsyslog::component::template::mytpl').with_content(
            %r{
              template\s\(name="mytpl"\stype="string"
              \s+string="/var/log/rsyslog/logs/%fromhost-ip%/%fromhost-ip%.log"
              \s+option\.sql="on"\)
            }x
          )
        end
      end

      context 'list template' do
        let(:params) do
          {
            type: 'list',
            priority: 30,
            target: '50_rsyslog.conf',
            confdir: '/etc/rsyslog.d',
            list_descriptions: [
              { 'constant' => { 'value' => '{' } },
              { 'constant' => { 'value' => '\"@timestamp\":\"' } },
              { 'property' => { 'name'  => 'timereported', 'dateformat' => 'rfc3339' } },
              { 'constant' => { 'value' => '\"}' } },
              { 'constant' => { 'value' => '\"message\\":\"' }, 'property' => { 'name' => 'msg', 'format' => 'json' } }
            ]
          }
        end

        it do
          is_expected.to contain_concat__fragment('rsyslog::component::template::mytpl').with_content(
            %r{template\s\(name="mytpl"\stype="list"\s\)
            \s+\{
            \s+constant\(value="\{"\s\)
            \s+constant\(value="\\"@timestamp\\":\\""\s\)
            \s+property\(name="timereported"\s+dateformat="rfc3339"\s\)
            \s+constant\(value="\\"\}"\s\)
            \s+constant\(value="\\"message\\":\\""\s\)\s+property\(name="msg"\s+format="json"\s\)
            }x
          )
        end
      end
    end
  end
end
