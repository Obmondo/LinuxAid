# frozen_string_literal: true

require 'spec_helper'

describe 'openvas::compose' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:params) do
        {
          install: true,
          compose_dir: '/opt/openvas',
          feed_release: '24.10',
          manage_docker: false,
          admin_password: 'test_password',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_file('/opt/openvas').with(
          ensure: 'directory',
        )
      end

      it do
        is_expected.to contain_file('/opt/openvas/docker-compose.yml').with(
          ensure: 'file',
        )
      end

      it do
        is_expected.to contain_file('/opt/openvas/docker-compose.yml').with_content(%r{restart: unless-stopped})
      end

      it do
        is_expected.to contain_docker_compose('openvas').with(
          ensure: 'present',
          compose_files: ['/opt/openvas/docker-compose.yml'],
        )
      end

      context 'when install is false' do
        let(:params) do
          super().merge(
            install: false,
            admin_password: 'test_password',
          )
        end

        it do
          is_expected.to contain_file('/opt/openvas').with(
            ensure: 'absent',
          )
        end

        it do
          is_expected.to contain_docker_compose('openvas').with(
            ensure: 'absent',
          )
        end
      end

    end
  end
end
