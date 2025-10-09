# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Actions::Outputs::Omhttpfs' do
  let(:data) do
    {
      host: 'localhost',
      port: 443,
      user: 'root',
      https: 'on',
      file: 'file',
      isdynfile: 'off',
      template: 't_http'
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
          expected_param[:file] = 'file' unless param.to_s == 'file'
          is_expected.to allow_value(expected_param)
        end
      end
    end
  end

  context 'with invalid data' do
    context 'bad strings' do
      let(:bad_strings) do
        {
          user: 0,
          https: false,
          file: '',
          isdynfile: true,
          template: ''
        }
      end

      it { is_expected.not_to allow_value(bad_strings) }
    end

    context 'bad integers' do
      let(:bad_int) do
        {
          port: '80'
        }
      end

      it { is_expected.not_to allow_value(bad_int) }
    end

    context 'bad ip address' do
      let(:bad_ip) do
        {
          host: '300.122.32.'
        }
      end

      it { is_expected.not_to allow_value(bad_ip) }
    end
  end
end
