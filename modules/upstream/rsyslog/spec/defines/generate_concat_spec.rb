# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Generate_concat', include_rsyslog: true do
  context 'default' do
    let(:pre_condition) { 'include rsyslog' }
    let(:title) { 'mygeneratedconcat' }

    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let :facts do
          os_facts
        end

        let(:params) do
          {
            confdir: '/etc/rsyslog.d',
            target: '50-rsyslog.conf'
          }
        end

        it 'contains rsyslog config with syslog service notification' do
          is_expected.to contain_concat('/etc/rsyslog.d/50-rsyslog.conf').that_notifies('Service[rsyslog]')
        end
      end
    end
  end
end
