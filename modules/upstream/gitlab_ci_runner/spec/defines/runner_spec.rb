require 'spec_helper'

describe 'gitlab_ci_runner::runner' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:title) { 'testrunner' }
      let(:default_params) do
        {
          config: {
            'registration-token' => 'gitlab-token',
            'url'                => 'https://gitlab.com'
          }
        }
      end

      context 'with default params' do
        let(:params) { default_params }

        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_exec('Register_runner_testrunner').with(
            command: '/usr/bin/gitlab-runner register -n --name=testrunner --registration-token=gitlab-token --url=https://gitlab.com',
            unless: "/bin/grep -F 'testrunner' /etc/gitlab-runner/config.toml"
          )
        end
      end

      context 'with ensure => absent' do
        let(:params) do
          default_params.merge(ensure: 'absent')
        end

        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_exec('Unregister_runner_testrunner').with(
            command: '/usr/bin/gitlab-runner unregister -n testrunner',
            onlyif: "/bin/grep -F 'testrunner' /etc/gitlab-runner/config.toml"
          )
        end
      end

      context 'with binary => special-gitlab-runner' do
        let(:params) { default_params.merge(binary: 'special-gitlab-runner') }

        context 'with ensure => present' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_exec('Register_runner_testrunner').with_command(%r{^/usr/bin/special-gitlab-runner}) }
        end

        context 'with ensure => absent' do
          let(:params) do
            super().merge(ensure: 'absent')
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_exec('Unregister_runner_testrunner').with_command(%r{^/usr/bin/special-gitlab-runner}) }
        end
      end

      context 'with config having a key containing _' do
        let(:params) do
          {
            config: {
              build_dir: '/tmp'
            }
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_exec('Register_runner_testrunner').with_command(%r{--build-dir=/tmp}) }
      end

      context 'with config having a key which has an array as value' do
        let(:params) do
          {
            config: {
              'docker-volumes' => ['test0:/test0', 'test1:/test1']
            }
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_exec('Register_runner_testrunner').with_command(%r{--docker-volumes=test0:/test0 --docker-volumes=test1:/test1}) }
      end
    end
  end
end
