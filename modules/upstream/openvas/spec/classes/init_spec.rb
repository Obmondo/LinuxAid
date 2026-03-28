# frozen_string_literal: true

require 'spec_helper'

describe 'openvas' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:pre_condition) do
        <<~PUPPET
          class docker {}
          class docker::compose {}
        PUPPET
      end

      let(:params) do
        {
          admin_password: 'test_password',
        }
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('docker') }
      it { is_expected.to contain_class('docker::compose') }
      it { is_expected.to contain_class('openvas::compose') }
      it { is_expected.to contain_class('openvas::firewall') }

      context 'when docker management is disabled' do
        let(:params) do
          {
            manage_docker: false,
            admin_password: 'test_password',
          }
        end

        it { is_expected.not_to contain_class('docker') }
        it { is_expected.not_to contain_class('docker::compose') }
      end

      context 'when openvas install is false' do
        let(:params) do
          {
            install: false,
            admin_password: 'test_password',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('docker') }
        it { is_expected.to contain_class('docker::compose') }
      end
    end
  end
end
