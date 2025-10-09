# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Inputs::Imfile' do
  let(:data) do
    {
      file: '/var/log/file.log',
      tag: 'tag',
      facility: 'kern',
      severity: 'info',
      persiststateinterval: 60,
      'startmsg.regex' => '^test$',
      'endmsg.regex' => '^end$',
      readtimeout: 10,
      readmode: 2,
      escapelf: 'off',
      maxlinesatonce: 100,
      maxsubmitatonce: 10,
      deletestateonfiledelete: 'on',
      ruleset: 'test_ruleset',
      addmetadata: 'off',
      addceetag: 'off',
      reopenontruncate: 'on',
      trimlineoverbytes: 1024,
      freshstarttail: 'off',
      discardtruncatedmsg: 'on',
      msgdiscardingerror: 'off',
      neeparse: 'on'
    }
  end

  context 'with valid data' do
    context 'full data' do
      it { is_expected.to allow_value(data) }
    end

    context 'individual parameters' do
      it 'is valid' do
        required_params = { file: data[:file], tag: data[:tag] }
        data.each do |param, value|
          expected_param = { param.to_sym => value }
          is_expected.to allow_value(expected_param.merge!(required_params))
        end
      end
    end
  end

  context 'with invalid data' do
    context 'missing defaults' do
      it 'file missing failure' do
        is_expected.not_to allow_value(tag: 'tag')
      end

      it 'tag missing failure' do
        is_expected.not_to allow_value(file: 'file')
      end
    end

    context 'bad strings' do
      let(:bad_strings) do
        {
          file: '',
          tag: '',
          'startmsg.regex' => '',
          'endmsg.regex' => '',
          ruleset: ''
        }
      end

      it { is_expected.not_to allow_value(:bad_strings) }
    end

    context 'bad_integers' do
      let(:bad_int) do
        {
          file: 'file',
          tag: 'tag',
          persiststateinterval: '100',
          readtimeout: '10m',
          maxlinesatonce: '100',
          maxsubmitatonce: nil,
          trimlineoverbytes: '1GB'
        }
      end

      it { is_expected.not_to allow_value(:bad_int) }
    end
  end
end
