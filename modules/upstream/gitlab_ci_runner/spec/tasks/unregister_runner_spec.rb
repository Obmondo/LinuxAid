require 'webmock/rspec'
require_relative '../../tasks/unregister_runner.rb'

describe UnregisterRunnerTask do
  let(:params) do
    {
      url: 'https://gitlab.example.org',
      token: 'abcdef1234'
    }
  end
  let(:task) { described_class.new }

  describe 'task' do
    it 'can unregister a runner' do
      stub_request(:delete, 'https://gitlab.example.org/api/v4/runners').
        with(body: { token: 'abcdef1234' }).
        to_return(body: nil)
      expect(task.task(params)).to eq(status: 'success')
    end

    it 'can raise an error' do
      params.merge(token: 'invalid-token')
      stub_request(:delete, 'https://gitlab.example.org/api/v4/runners').
        to_return(status: [403, 'Forbidden'])
      expect { task.task(params) }.to raise_error(TaskHelper::Error, %r{Gitlab runner failed to unregister: Forbidden})
    end
  end
end
