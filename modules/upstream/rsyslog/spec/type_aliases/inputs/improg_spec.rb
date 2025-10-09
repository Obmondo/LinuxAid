# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Inputs::Improg' do
  let(:data) do
    {
      binary: '/usr/local/bin/grep /foo/bar',
      tag: 'tag',
      facility: 'kern',
      severity: 'info',
      confirmmessages: 'off',
      signalonclose: 'on',
      closetimeout: 100,
      killunresponsive: 'off'
    }
  end

  context 'valid data' do
    context 'full data' do
      it { is_expected.to allow_value(data) }
    end

    context 'individual parameters' do
      it 'is valid' do
        required_params = { binary: data[:binary], tag: data[:tag] }
        data.each do |param, value|
          is_expected.to allow_value({ param.to_sym => value }.merge!(required_params))
        end
      end
    end
  end

  context 'invalid data' do
    context 'missing required params' do
      it 'fails without binary' do
        is_expected.not_to allow_value(tag: 'tag')
      end

      it 'fails without tag' do
        is_expected.not_to allow_value(binary: 'binary')
      end
    end

    context 'invalid data type' do
      context 'invalid strings' do
        let(:bad_strings) do
          {
            binary: true,
            tag: '',
            confirmmessages: false,
            signalonclose: true,
            killunresponsive: false
          }
        end

        it { is_expected.not_to allow_value(bad_strings) }
      end

      context 'invalid integer' do
        let(:bad_number) do
          {
            binary: '/bin/cat file',
            tag: 'tag',
            closetimeout: '100'
          }
        end

        it { is_expected.not_to allow_value(bad_number) }
      end
    end
  end
end
