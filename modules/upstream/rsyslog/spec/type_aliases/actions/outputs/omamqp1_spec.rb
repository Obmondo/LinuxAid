# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Actions::Outputs::Omamqp1' do
  context 'with minimum valid data' do
    let(:data) do
      {
        host: 'localhost',
        target: 'amq.topic'
      }
    end

    it { is_expected.to allow_value(data) }
  end

  context 'with valid data' do
    context 'using all options' do
      let(:data) do
        {
          host: 'localhost',
          target: 'amq.topic',
          username: 'foo',
          password: 'bar',
          template: 'amq_template',
          idletimeout: 10,
          reconnectdelay: 30,
          maxretries: 2,
          disablesasl: 0
        }
      end

      it { is_expected.to allow_value(data) }
    end

    context 'using partial options' do
      let(:data) do
        {
          host: 'localhost',
          target: 'amq.topic',
          reconnectdelay: 30,
          maxretries: 2
        }
      end

      it { is_expected.to allow_value(data) }
    end
  end

  context 'with invalid data' do
    context 'missing required parameter' do
      let(:data) do
        {
          target: 'amq.topic',
          reconnectdelay: 30,
          maxretries: 2
        }
      end

      it { is_expected.not_to allow_value(data) }
    end

    context 'invalid data types' do
      let(:data) do
        {
          host: '',
          target: 'amq.topic',
          reconnectdelay: '30'
        }
      end

      it { is_expected.not_to allow_value(data) }
    end
  end
end
