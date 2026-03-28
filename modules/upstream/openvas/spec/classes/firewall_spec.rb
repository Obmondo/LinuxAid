# frozen_string_literal: true

require 'spec_helper'

describe 'openvas::firewall' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:params) do
        {
          install: true,
          expose: true,
          web_port: 9392,
        }
      end

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_firewall_multi('000 allow openvas web interface').with(
          ensure: 'present',
          dport: 9392,
          proto: 'tcp',
          jump: 'accept',
        )
      end

      context 'when expose is false' do
        let(:params) do
          super().merge(
            expose: false,
          )
        end

        it do
          is_expected.to contain_firewall_multi('000 allow openvas web interface').with(
            ensure: 'absent',
          )
        end
      end
    end
  end
end
