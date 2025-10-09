# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Inputs::Imbatchreports' do
  let(:data) do
    {
      reports: 'report',
      tag: 'tag',
      facility: 'kern',
      severity: 'info',
      deduplicatespaces: 'off',
      delete: '.ok$ .rejected',
      rename: '.ok$ .sent .rejected',
      programkey: 'APPNAME',
      timestampkey: 'TIMESTAMP'
    }
  end

  context 'with valid data' do
    context 'full data' do
      it { is_expected.to allow_value(data) }
    end

    context 'individual parameters' do
      it 'is valid' do
        required_params = { reports: data[:reports], tag: data[:tag] }
        data.each do |param, value|
          expected_param = { param.to_sym => value }
          is_expected.to allow_value(expected_param.merge!(required_params))
        end
      end
    end
  end

  context 'with invalid data' do
    context 'missing_defaults' do
      it 'fails missing a default' do
        %w[reports tag].each do |param|
          is_expected.not_to allow_value(param.to_sym => param)
        end
      end
    end

    context 'bad_strings' do
      let(:bad_strings) do
        {
          reports: 10,
          tag: '',
          delete: true,
          rename: false,
          programkey: '',
          timestampkey: 20_151_011
        }
      end

      it { is_expected.not_to allow_value(bad_strings) }
    end
  end
end
