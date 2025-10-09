# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Inputs::Imkafka' do
  let(:data) do
    {
      broker: 'localhost:9092',
      topic: 'foo',
      confparam: %w[bar baz test],
      consumergroup: 'group',
      ruleset: 'kafka_ruleset',
      parsehostname: 'on'
    }
  end

  context 'with valid data' do
    context 'full data' do
      it { is_expected.to allow_value(data) }
    end

    context 'individual parameters' do
      it 'is valid' do
        required_params = { topic: data[:topic] }
        data.each do |param, value|
          is_expected.to allow_value({ param.to_sym => value }.merge!(required_params))
        end
      end
    end
  end

  context 'with invalid data' do
    context 'missing defaults' do
      it { is_expected.not_to allow_value(topic: '') }
    end

    context 'bad strings' do
      let(:bad_strings) do
        {
          broker: '',
          topic: '',
          consumergroup: '',
          ruleset: '',
          parsehostname: false
        }
      end

      it { is_expected.not_to allow_value(bad_strings) }
    end

    context 'bad array' do
      let(:bad_array) do
        {
          topic: 'foo',
          confparam: 'bar'
        }
      end

      it { is_expected.not_to allow_value(bad_array) }
    end
  end
end
