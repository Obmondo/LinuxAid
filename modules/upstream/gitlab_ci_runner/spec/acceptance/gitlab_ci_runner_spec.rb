require 'spec_helper_acceptance'

describe 'gitlab_ci_runner class' do
  # We run a sidecar Gitlab container next to acceptance tests.
  # See puppet-gitlab_ci_runner/scripts/start-gitlab.sh
  let(:registrationtoken) do
    File.read(File.expand_path('~/INSTANCE_TOKEN')).chomp
  end

  context 'default parameters' do
    it 'idempotently with no errors' do
      pp = <<-EOS
      class { 'gitlab_ci_runner':
        manage_docker   => false,
        runners         => {
          test_runner => {}
        },
        runner_defaults => {
          url                => 'http://gitlab',
          registration-token => '#{registrationtoken}',
          executor           => 'shell',
        }
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe package('gitlab-runner') do
      it { is_expected.to be_installed }
    end

    describe service('gitlab-runner') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    it 'registered the runner' do
      authtoken = shell("grep 'token = ' /etc/gitlab-runner/config.toml | cut -d '\"' -f2").stdout
      shell("/usr/bin/env curl -X POST --form 'token=#{authtoken}' http://gitlab/api/v4/runners/verify") do |r|
        expect(r.stdout).to eq('200')
      end
    end
  end
end
