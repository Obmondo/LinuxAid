require 'spec_helper_acceptance'
require 'json'

describe 'Gitlab Runner bolt tasks' do
  let(:registrationtoken) do
    File.read(File.expand_path('~/INSTANCE_TOKEN')).chomp
  end

  describe 'register_runner' do
    context 'registers a runner' do
      let(:result) do
        result = shell("bolt task run gitlab_ci_runner::register_runner --format json --targets localhost url=http://gitlab token=#{registrationtoken}").stdout.chomp
        JSON.parse(result)['items'][0]['value']
      end

      it 'returns a valid token' do
        expect(result['token']).to be_instance_of(String)
      end

      it 'returns  a runner id' do
        expect(result['id']).to be_instance_of(Integer)
      end
    end

    context 'returns error on failure' do
      let(:result) do
        result = shell('bolt task run gitlab_ci_runner::register_runner --format json --targets localhost url=http://gitlab token=wrong-token', acceptable_exit_codes: [0, 2]).stdout.chomp
        JSON.parse(result)['items'][0]['value']
      end

      it 'returns the correct exception' do
        expect(result['_error']['kind']).to eq('bolt-plugin/gitlab-ci-runner-register-error')
      end
    end
  end

  describe 'unregister_runner' do
    context 'unregisters a runner' do
      let(:authtoken) do
        result = shell("bolt task run gitlab_ci_runner::register_runner --format json --targets localhost url=http://gitlab token=#{registrationtoken}").stdout.chomp
        JSON.parse(result)['items'][0]['value']['token']
      end
      let(:result) do
        result = shell("bolt task run gitlab_ci_runner::unregister_runner --format json --targets localhost url=http://gitlab token=#{authtoken}").stdout.chomp
        JSON.parse(result)['items'][0]['value']
      end

      it 'succeeds' do
        expect(result['status']).to eq('success')
      end
    end

    context 'returns error on failure' do
      let(:result) do
        result = shell('bolt task run gitlab_ci_runner::unregister_runner --format json --targets localhost url=http://gitlab token=wrong-token', acceptable_exit_codes: [0, 2]).stdout.chomp
        JSON.parse(result)['items'][0]['value']
      end

      it 'returns the correct exception' do
        expect(result['_error']['kind']).to eq('bolt-plugin/gitlab-ci-runner-unregister-error')
      end
    end
  end
end
