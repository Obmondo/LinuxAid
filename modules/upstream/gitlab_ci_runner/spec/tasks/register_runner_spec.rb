require 'webmock/rspec'
require_relative '../../tasks/register_runner.rb'

describe RegisterRunnerTask do
  let(:params) do
    {
      url: 'https://gitlab.example.org',
      token: 'abcdef1234'
    }
  end
  let(:task) { described_class.new }

  describe 'task' do
    it 'can register a runner' do
      stub_request(:post, 'https://gitlab.example.org/api/v4/runners').
        with(body: { token: 'abcdef1234' }).
        to_return(body: '{"id": 777, "token": "3bz5wqfDiYBhxoUNuGVu"}')
      expect(task.task(params)).to eq('id' => 777, 'token' => '3bz5wqfDiYBhxoUNuGVu')
    end

    it 'can raise an error' do
      params.merge(token: 'invalid-token')
      stub_request(:post, 'https://gitlab.example.org/api/v4/runners').
        to_return(status: [403, 'Forbidden'])
      expect { task.task(params) }.to raise_error(TaskHelper::Error, %r{Gitlab runner failed to register: Forbidden})
    end
  end
end
