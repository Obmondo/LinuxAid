# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Actions::Outputs::Omhiredis' do
  let(:data) do
    {
      server: 'localhost',
      serverport: 80,
      serverpassword: 'foo',
      mode: 'queue',
      template: 't_redis',
      key: 'main',
      userpush: 'off'
    }
  end

  context 'with valid data' do
    context 'full data' do
      it { is_expected.to allow_value(data) }
    end

    context 'individual parameters' do
      it 'is valid' do
        data.each do |param, value|
          expected_param = { param.to_sym => value }
          is_expected.to allow_value(expected_param)
        end
      end
    end
  end

  context 'with invalid data' do
    context 'bad strings' do
      let(:bad_strings) do
        {
          serverpassword: '',
          mode: 'user',
          template: '',
          key: '',
          userpush: true
        }
      end

      it { is_expected.not_to allow_value(bad_strings) }
    end

    context 'bad integers' do
      let(:bad_int) do
        {
          serverport: '80'
        }
      end

      it { is_expected.not_to allow_value(bad_int) }
    end

    context 'bad ip address' do
      let(:bad_ip) do
        {
          server: '300.122.32.'
        }
      end

      it { is_expected.not_to allow_value(bad_ip) }
    end
  end
end
