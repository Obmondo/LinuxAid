# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Actions::Outputs::Omkafka' do
  let(:data) do
    {
      broker: 'foo',
      topic: 'default',
      key: 'primary',
      dynatopic: 'off',
      'dynatopic.cachesize' => 512,
      'partitions.auto' => 'off',
      'partitions.number' => 10,
      'partitions.usefixed' => 0,
      errorfile: 'error.log',
      confparam: %w[param1 param2],
      topicconfparam: %w[param1 param2],
      template: 't_kafka',
      closetimeout: 600,
      resubmitonfailure: 'on',
      keepfailedmessages: 'off',
      failedmsgfile: 'message'
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
          expected_param[:topic] = 'topic' unless param.to_s == 'topic'
          is_expected.to allow_value(expected_param)
        end
      end
    end
  end

  context 'with invalid data' do
    context 'bad strings' do
      let(:bad_strings) do
        {
          broker: '',
          topic: 1,
          key: 4,
          dynatopic: true,
          'partitions.auto' => false,
          errorfile: '',
          confparam: [0, 1],
          topicconfparam: [0, 1],
          template: '',
          resubmitonfailure: false,
          keepfailedmessages: true,
          failedmsgfile: ''
        }
      end

      it { is_expected.not_to allow_value(bad_strings) }
    end

    context 'bad integers' do
      let(:bad_int) do
        {
          'dynatopic.cachesize' => '50m',
          'partitions.number' => '50',
          'partitions.usefixed' => '0',
          closetimeout: '5h'
        }
      end

      it { is_expected.not_to allow_value(bad_int) }
    end

    context 'bad array' do
      let(:bad_array) do
        {
          confparam: 'param1',
          topicconfparam: 'param2'
        }
      end

      it { is_expected.not_to allow_value(bad_array) }
    end
  end
end
